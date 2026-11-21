using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;

internal sealed class BuildMonitor : Form
{
    private static readonly string[] LogNames = { "build", "unity", "xcode" };
    private static readonly Regex JobPattern = new Regex(@"^[0-9]{8}T[0-9]{6}Z-[0-9a-f]{40}-[0-9]+$");
    private static readonly Color Ink = Color.FromArgb(23, 37, 54);
    private static readonly Color Muted = Color.FromArgb(83, 101, 123);
    private readonly string repository;
    private readonly string cache;
    private readonly string host;
    private readonly string ssh;
    private readonly string identity;
    private readonly string remoteScript;
    private readonly ListBox jobs = new ListBox();
    private readonly Label connection = new Label();
    private readonly Label title = new Label();
    private readonly Label stages = new Label();
    private readonly ComboBox logPicker = new ComboBox();
    private readonly CheckBox follow = new CheckBox();
    private readonly RichTextBox log = new RichTextBox();
    private readonly Timer timer = new Timer();
    private Dictionary<string, Job> jobDetails = new Dictionary<string, Job>();
    private bool refreshing;
    private bool updatingList;

    [STAThread]
    private static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        try
        {
            Application.Run(new BuildMonitor());
        }
        catch (Exception error)
        {
            MessageBox.Show(error.Message, "iOS 构建日志", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private BuildMonitor()
    {
        repository = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", ".."));
        cache = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "logs");
        Directory.CreateDirectory(cache);
        var gitFolder = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Git");
        ssh = Path.Combine(gitFolder, "usr", "bin", "ssh.exe");
        var git = Path.Combine(gitFolder, "cmd", "git.exe");
        identity = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".ssh", "probablystolen_vm_ed25519");
        if (!File.Exists(ssh)) throw new InvalidOperationException("找不到 Git for Windows 的 SSH 工具。");

        host = RunAsync(git, "config --local --get port.iosVmHost", null).GetAwaiter().GetResult().Trim();
        if (!Regex.IsMatch(host, @"^[a-zA-Z0-9._][a-zA-Z0-9._-]*@[a-zA-Z0-9.-]+$"))
            throw new InvalidOperationException("该工作区还没有配置 Mac 构建主机。");

        using (var reader = new StreamReader(Assembly.GetExecutingAssembly().GetManifestResourceStream("read-vm-logs.sh")))
            remoteScript = reader.ReadToEnd().Replace("\r\n", "\n");

        CreateLayout();
        timer.Interval = 2500;
        timer.Tick += async (sender, args) => await RefreshAsync();
        Shown += async (sender, args) => { timer.Start(); await RefreshAsync(); };
        FormClosing += (sender, args) => timer.Stop();
    }

    private void CreateLayout()
    {
        Text = "ProbablyStolen-ios | 构建日志";
        StartPosition = FormStartPosition.CenterScreen;
        ClientSize = new Size(1110, 730);
        MinimumSize = new Size(840, 500);
        Font = new Font("Microsoft YaHei UI", 10);
        ForeColor = Ink;
        BackColor = Color.White;

        var layout = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(18), RowCount = 2, ColumnCount = 2 };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 218));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 58));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        var header = new Label
        {
            Text = "iOS 构建日志", Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft,
            Font = new Font(Font.FontFamily, 19, FontStyle.Bold)
        };
        connection.Text = "正在连接 Mac…";
        connection.Dock = DockStyle.Fill;
        connection.TextAlign = ContentAlignment.MiddleRight;
        connection.AutoEllipsis = true;
        connection.ForeColor = Muted;
        layout.Controls.Add(header, 0, 0);
        layout.Controls.Add(connection, 1, 0);

        var sidebar = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 2, ColumnCount = 1, Padding = new Padding(0, 0, 12, 0) };
        sidebar.RowStyles.Add(new RowStyle(SizeType.Absolute, 30));
        sidebar.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        sidebar.Controls.Add(new Label { Text = "构建记录", Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft }, 0, 0);
        jobs.Dock = DockStyle.Fill;
        jobs.BorderStyle = BorderStyle.FixedSingle;
        jobs.IntegralHeight = false;
        jobs.DrawMode = DrawMode.OwnerDrawFixed;
        jobs.ItemHeight = 50;
        jobs.DrawItem += DrawJob;
        jobs.SelectedIndexChanged += async (sender, args) =>
        {
            if (updatingList) return;
            RenderSelection(true);
            await RefreshAsync();
        };
        sidebar.Controls.Add(jobs, 0, 1);
        layout.Controls.Add(sidebar, 0, 1);

        var details = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 4, ColumnCount = 1 };
        details.RowStyles.Add(new RowStyle(SizeType.Absolute, 30));
        details.RowStyles.Add(new RowStyle(SizeType.Absolute, 33));
        details.RowStyles.Add(new RowStyle(SizeType.Absolute, 42));
        details.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        title.Dock = DockStyle.Fill;
        title.Font = new Font(Font.FontFamily, 13, FontStyle.Bold);
        stages.Dock = DockStyle.Fill;
        stages.ForeColor = Muted;
        stages.AutoEllipsis = true;
        details.Controls.Add(title, 0, 0);
        details.Controls.Add(stages, 0, 1);

        var controls = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, WrapContents = false };
        logPicker.DropDownStyle = ComboBoxStyle.DropDownList;
        logPicker.Width = 136;
        logPicker.Items.AddRange(new object[] { "总日志", "Unity 导出", "Xcode 编译" });
        logPicker.SelectedIndex = 0;
        logPicker.SelectedIndexChanged += (sender, args) => RenderSelection(true);
        follow.Text = "跟随输出";
        follow.AutoSize = true;
        follow.Checked = true;
        follow.Margin = new Padding(12, 6, 12, 0);
        follow.CheckedChanged += (sender, args) => { if (follow.Checked) RenderSelection(true); };
        var refresh = new Button { Text = "刷新", AutoSize = true };
        refresh.Click += async (sender, args) => await RefreshAsync();
        var showFiles = new Button { Text = "打开日志目录", AutoSize = true };
        showFiles.Click += (sender, args) =>
        {
            string directory = SelectedId == null ? cache : Path.Combine(cache, SelectedId);
            Directory.CreateDirectory(directory);
            Process.Start("explorer.exe", Quote(directory));
        };
        controls.Controls.AddRange(new Control[] { logPicker, follow, refresh, showFiles });
        details.Controls.Add(controls, 0, 2);

        log.Dock = DockStyle.Fill;
        log.ReadOnly = true;
        log.DetectUrls = false;
        log.WordWrap = true;
        log.BackColor = Color.FromArgb(20, 28, 42);
        log.ForeColor = Color.FromArgb(224, 234, 246);
        log.BorderStyle = BorderStyle.FixedSingle;
        log.Font = new Font("Consolas", 10);
        details.Controls.Add(log, 0, 3);
        layout.Controls.Add(details, 1, 1);
        Controls.Add(layout);
        RenderSelection(true);
    }

    private string SelectedId { get { return jobs.SelectedItem as string; } }

    private void DrawJob(object sender, DrawItemEventArgs args)
    {
        if (args.Index < 0) return;
        var item = jobDetails[(string)jobs.Items[args.Index]];
        bool selected = (args.State & DrawItemState.Selected) != 0;
        Color background = selected ? Color.FromArgb(223, 237, 255) : Color.White;
        using (var brush = new SolidBrush(background)) args.Graphics.FillRectangle(brush, args.Bounds);
        TextRenderer.DrawText(args.Graphics, item.ShortId + "  " + StateLabel(item.State), Font,
            new Point(args.Bounds.X + 9, args.Bounds.Y + 5), Ink);
        TextRenderer.DrawText(args.Graphics, item.LocalTime, Font,
            new Point(args.Bounds.X + 9, args.Bounds.Y + 26), Muted);
        args.DrawFocusRectangle();
    }

    private async Task RefreshAsync()
    {
        if (refreshing || IsDisposed) return;
        refreshing = true;
        string requestedJob = SelectedId;
        try
        {
            var offsets = LogNames.Select(name => GetOffset(requestedJob, name).ToString(CultureInfo.InvariantCulture));
            string remote = "sh -s -- " + (requestedJob ?? "none") + " " + string.Join(" ", offsets);
            string options = "-C -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=yes";
            if (File.Exists(identity)) options += " -o IdentitiesOnly=yes -i " + Quote(identity);
            string response = await RunAsync(ssh, options + " " + Quote(host) + " " + Quote(remote), remoteScript);
            if (IsDisposed) return;

            var incoming = new Dictionary<string, Job>();
            foreach (string line in response.Split('\n'))
            {
                string[] fields = line.TrimEnd('\r').Split('|');
                if (fields.Length == 4 && fields[0] == "J" && JobPattern.IsMatch(fields[1]))
                    incoming[fields[1]] = new Job(fields[1], fields[2], fields[3] == "1");
                if (fields.Length == 4 && fields[0] == "L" && requestedJob != null && LogNames.Contains(fields[1]))
                    SaveChunk(requestedJob, fields[1], fields[2], fields[3]);
            }

            jobDetails = incoming;
            UpdateList();
            connection.Text = "Mac 已连接 · " + DateTime.Now.ToString("HH:mm:ss");
            RenderSelection(false);
        }
        catch (Exception error)
        {
            if (!IsDisposed)
            {
                connection.Text = "连接或读取失败 · 自动重试";
                File.WriteAllText(Path.Combine(cache, "connection-error.txt"), error.Message);
            }
        }
        finally { refreshing = false; }
    }

    private void UpdateList()
    {
        string selected = SelectedId;
        string[] ids = jobDetails.Keys.OrderByDescending(id => id, StringComparer.Ordinal).ToArray();
        if (!jobs.Items.Cast<string>().SequenceEqual(ids))
        {
            updatingList = true;
            jobs.BeginUpdate();
            try
            {
                jobs.Items.Clear();
                jobs.Items.AddRange(ids);
                jobs.SelectedIndex = Array.IndexOf(ids, selected);
                if (jobs.SelectedIndex < 0 && ids.Length > 0) jobs.SelectedIndex = 0;
            }
            finally { jobs.EndUpdate(); updatingList = false; }
        }
        jobs.Invalidate();
    }

    private void RenderSelection(bool force)
    {
        string id = SelectedId;
        if (id == null)
        {
            title.Text = "等待构建任务";
            stages.Text = "Mac 接到提交后，任务会显示在左侧。";
            log.Clear();
            return;
        }

        var item = jobDetails[id];
        title.Text = item.ShortId + "   " + StateLabel(item.State);
        stages.Text = "提交 " + item.Commit + (item.HasIpa ? "   ·   IPA 已在 Mac 生成" : "");
        var directory = Path.Combine(cache, id);
        Directory.CreateDirectory(directory);
        File.WriteAllText(Path.Combine(cache, "selected.txt"), id);
        File.WriteAllText(Path.Combine(directory, "status.txt"), item.State + Environment.NewLine + item.Commit);
        if (!force && !follow.Checked) return;

        string file = Path.Combine(directory, LogNames[logPicker.SelectedIndex] + ".log");
        string content = File.Exists(file) ? ReadTail(file) : "等待该步骤输出…";
        if (content == log.Text) return;
        log.Text = content;
        if (follow.Checked)
        {
            log.SelectionStart = log.TextLength;
            log.ScrollToCaret();
        }
    }

    private static string ReadTail(string file)
    {
        const int displayLimit = 160 * 1024;
        using (var stream = File.OpenRead(file))
        {
            bool truncated = stream.Length > displayLimit;
            if (truncated) stream.Seek(-displayLimit, SeekOrigin.End);
            using (var reader = new StreamReader(stream, Encoding.UTF8, true))
            {
                if (truncated) reader.ReadLine();
                return (truncated ? "更早的内容请打开缓存日志查看。\r\n\r\n" : "") + reader.ReadToEnd();
            }
        }
    }

    private long GetOffset(string id, string name)
    {
        if (id == null) return 0;
        var file = new FileInfo(Path.Combine(cache, id, name + ".log"));
        return file.Exists ? file.Length : 0;
    }

    private void SaveChunk(string id, string name, string position, string payload)
    {
        long offset;
        if (!long.TryParse(position, NumberStyles.None, CultureInfo.InvariantCulture, out offset)) return;
        byte[] bytes = Convert.FromBase64String(payload);
        if (bytes.Length == 0 && offset == GetOffset(id, name)) return;
        string directory = Path.Combine(cache, id);
        Directory.CreateDirectory(directory);
        using (var stream = new FileStream(Path.Combine(directory, name + ".log"), FileMode.OpenOrCreate, FileAccess.Write))
        {
            if (stream.Length < offset) return;
            stream.SetLength(offset);
            stream.Position = offset;
            stream.Write(bytes, 0, bytes.Length);
        }
    }

    private async Task<string> RunAsync(string program, string arguments, string input)
    {
        var start = new ProcessStartInfo(program, arguments)
        {
            WorkingDirectory = repository, UseShellExecute = false, CreateNoWindow = true,
            RedirectStandardOutput = true, RedirectStandardError = true, RedirectStandardInput = input != null
        };
        using (var process = Process.Start(start))
        {
            var stdout = process.StandardOutput.ReadToEndAsync();
            var stderr = process.StandardError.ReadToEndAsync();
            if (input != null)
            {
                byte[] bytes = Encoding.UTF8.GetBytes(input);
                await process.StandardInput.BaseStream.WriteAsync(bytes, 0, bytes.Length).ConfigureAwait(false);
                process.StandardInput.Close();
            }
            if (!await Task.Run(() => process.WaitForExit(18000)).ConfigureAwait(false))
            {
                try { process.Kill(); } catch (InvalidOperationException) { }
                throw new TimeoutException("读取构建主机日志超时。");
            }
            if (process.ExitCode != 0) throw new InvalidOperationException((await stderr.ConfigureAwait(false)).Trim());
            return await stdout.ConfigureAwait(false);
        }
    }

    private static string Quote(string value) { return "\"" + value + "\""; }

    private static string StateLabel(string state)
    {
        switch (state)
        {
            case "queued": return "等待 Mac";
            case "starting": return "准备源码";
            case "unity": return "Unity 导出中";
            case "xcode": return "Xcode 编译中";
            case "succeeded": return "构建成功";
            case "failed": return "构建失败";
            default: return "状态未知";
        }
    }

    private sealed class Job
    {
        public readonly string Commit;
        public readonly string State;
        public readonly bool HasIpa;
        public readonly string LocalTime;
        public string ShortId { get { return Commit.Substring(0, 8); } }

        public Job(string id, string state, bool hasIpa)
        {
            Commit = id.Substring(17, 40);
            State = state;
            HasIpa = hasIpa;
            DateTime utc;
            LocalTime = DateTime.TryParseExact(id.Substring(0, 16), "yyyyMMdd'T'HHmmss'Z'", CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal, out utc)
                ? utc.ToLocalTime().ToString("MM-dd HH:mm:ss") : id.Substring(0, 16);
        }
    }
}

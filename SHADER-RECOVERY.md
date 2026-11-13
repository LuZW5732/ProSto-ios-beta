# IPA shader recovery candidates

The previous Unity validation found 23 dummy shaders. These files now contain HLSL candidates translated from readable generated Metal source embedded in the supplied IPA (Unity 2021.3.45f2). This does not require AssetRipper's paid decompiler. Original shader names and existing `.meta` GUIDs are preserved; materials are unchanged.

Scope: 18 Easy Performant Outline shaders plus Emporium/ScratchBrushPixel, QFSW/Blur, Sprites/SolidBlend, UI/Grayscale and UI/ScratchReveal. The translation preserves recorded keywords, instanced object matrices, texture-array branches, property metadata, blend/depth/stencil states and the IPA's named QFSW GrabPass. Only D3D11 and Metal are targeted.

Local verification (2026-11-13):

- All 285 generated keyword combinations select exactly one recovered program per stage; all 570 recorded stage programs are reachable.
- Compiled both entry points of each complete generated HLSL pass with Windows D3DCompiler SM5 and official Unity 2021.3.45f2 includes: 570 compilations, zero errors, zero warnings. This checks HLSL and engine macros, not Unity's ShaderLab parser or Metal compiler.
- Repeat generation produces identical content. Output hashes match both local project copies; all 46 existing shader metadata files are unchanged.
- Static project audit: zero dummy shaders, zero duplicate GUIDs; four previously unresolved GUIDs remain (15 script references among their uses).

Limitations: these are older IPA shader behaviors, not recovered original PC source. Some IPA property metadata differs from the PC game. Compilation does not prove matching graphics, interpolation precision, stencil behavior, framebuffer orientation or instancing on a device. Unity import checks do not exhaustively compile every runtime variant. Full Metal build and manual checks of outlines, blur, grayscale, sprites and scratch reveal remain necessary. No new IPA has been built.

The raw input blobs, intermediate compiler tests and backups remain local. Reproduction scripts are `ios-port/recover_metal_shaders.py` and `ios-port/check_recovered_hlsl.py` in the preparation workspace; the corresponding local report directory is `ios-port/local/metal-recovery/`.

References: [Unity 2021.3.45f2 release and builtin shaders](https://unity.com/releases/editor/whats-new/2021.3.45f2), [ShaderLab ColorMask](https://docs.unity3d.com/2021.3/Documentation/Manual/SL-ColorMask.html), [sampler states](https://docs.unity3d.com/2021.3/Documentation/Manual/SL-SamplerStates.html).

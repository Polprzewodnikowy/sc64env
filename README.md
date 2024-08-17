# sc64env


Docker build environment for SummerCart64 repository

Image contains:
- Libdragon N64 SDK [fe168f22058faf11a9655867b6698191f3c59e69](https://github.com/DragonMinded/libdragon/commit/fe168f22058faf11a9655867b6698191f3c59e69)
- RISC-V RV32I/ILP32 GNU Toolchain [tags/2024.08.06](https://github.com/riscv-collab/riscv-gnu-toolchain/tree/2024.08.06)
- ARM GNU Toolchain [13.3.rel1](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
- Lattice Diamond [3.13](https://www.latticesemi.com/en/Products/DesignSoftwareAndIP/FPGAandLDS/LatticeDiamond)
- Python 3 with packages:
  - Pillow
- Extra packages:
  - bc
  - git
  - make
  - wget
  - zip

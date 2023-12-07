# sc64env


Docker build environment for SummerCart64 repository

Image contains:
- Libdragon N64 SDK [f6acabff638d8b1d4e5777ee23acf32906a4f397](https://github.com/DragonMinded/libdragon/commit/f6acabff638d8b1d4e5777ee23acf32906a4f397)
- RISC-V RV32I/ILP32 GNU Toolchain [tags/2023.11.22](https://github.com/riscv-collab/riscv-gnu-toolchain/tree/8e9fb09a0c4b1e566492ee6f42e8c1fa5ef7e0c2)
- ARM GNU Toolchain [13.2.rel1](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
- Lattice Diamond [3.13](https://www.latticesemi.com/en/Products/DesignSoftwareAndIP/FPGAandLDS/LatticeDiamond)
- Python 3 with packages:
  - Pillow
- Extra packages:
  - bc
  - git
  - make
  - wget
  - zip

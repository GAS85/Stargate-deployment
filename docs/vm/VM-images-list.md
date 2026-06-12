# VM Images list

Here you can find a current VM images list for different platforms. Please do not forget to check the SHA-256 hash of downloaded images. You can use the https://images.hin.ch/vm-images/SHA256SUMS file to compare it.

??? info "How to perform SHA256 hash check locally"

    You can calculate the SHA256 hash of downloaded files with the following command and then compare it with the values in the table below.

    === "Linux and macOS"

        Open Terminal and execute:

        ```bash
        sha256sum <File Name>
        ```

        As a more advanced variant, you can execute the following command and paste the predefined checksum as `SHA256_VALUE` and the file name as `IMAGE_NAME`:

        ```bash
        SHA256_VALUE="" \
        IMAGE_NAME="" \
        echo "$SHA256_VALUE  $IMAGE_NAME" | sudo sha256sum --check --status
        ```

    === "Windows"

        Open PowerShell and execute:

        ```powershell
        Get-FileHash "<File Name>"
        ```

        You can add the `-Algorithm SHA256` argument to force SHA256 use.

<!-- Script will replace everything AFTER this line -->
| Image name | Image Type | Image Size | Link | SHA256 Checksum |
| :--------- | :--------: | :--------- | :--: | :-------------- |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>255 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.mf) | `f2f0e5de30dca79647dfe7230ce9cbc62ff4d6ee4d595df65899bb17837cf1e1` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7684 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.ovf) | `f346eec52537dce7cac8cc4699e7382dfa6487994042488624472a8ee3280a73` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 959M /<br>1005516800 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.ova) | `f38393f844b61746b42174218fc2ccb31a9eb954ee7dd0d0163014bced676125` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1638662144 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.qcow2) | `89327f1886b419e11f95a23a1a54122e20c3c0f4e21a3e01386e0c3aecb2d816` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 30G /<br>32212254720 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.raw) | `4167b0bb8c5d35624b715f95f25030cfa3b312d145e10626e125bae082bb9227` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 967M /<br>1013928780 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.raw.gz) | `8bc495aee9d2575902b2c6db25a09263c5d1346abcbd243705d4ca1534623d34` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 31G /<br>32212255232 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vhd) | `9e1528602e683df2caf0eba0a969e92de656a1f875b20525370138d3153ce38b` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 976M /<br>1022891947 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vhd.gz) | `3d7ea97d5fcc7b28a68df32485d7721f92f1fda415606d229240a7177d25b345` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.1G /<br>2239758336 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vhdx) | `93236803d522904c57933fa1315bf104017a759b9e9987948213dc0665a2231f` |
| `Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 959M /<br>1005504512 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606120607.SGpreprod-v0.5.0-rc3.x86_64.vmdk) | `07b29333a3d0ae5bf4cacedb63c46d4a277e4d0d530e404909e1d540f6101545` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1209 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `e95384a1ab20810a1d1e7f5d806a62adae15a0426df76bb3d7ddf521f2075fd7` |

<!-- Script will replace everything BEFORE this line -->

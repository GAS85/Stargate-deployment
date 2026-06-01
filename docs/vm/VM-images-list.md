# VM Images list

Here you can find an actual VM images list for different platforms. Please do not forget to check SHA-256 Hash of downloaded images. You can use a https://images.hin.ch/vm-images/SHA256SUMS file to compare it.

??? info "How to perform SHA256 Hash check locally"

    You can calculate SHA256 Hash of downloaded files by following command and then compare it with values in a table below.

    === "Linux and MacOS"

        Open Terminal and execute:

        ```bash
        sha256sum <File Name>
        ```

        As move advanced variant you can execute following command and paste predefined Checksum as `SHA256_VALUE` and File Name as `IMAGE_NAME`:

        ```bash
        SHA256_VALUE="" \
        IMAGE_NAME="" \
        echo "$SHA256_VALUE  $IMAGE_NAME" | sudo sha1sum --check --status
        ```

    === "Windows"

        Open Powershell and execute:

        ```powershell
        Get-FileHash "<File Name>"
        ```

        You can add `-Algorithm SHA256` argument to force SHA256 use.

<!-- Script will replace everything AFTER this line -->
| Image name | Image Type | Image Size | Link | SHA256 Checksum |
| :--------- | :--------: | :--------- | :--: | :-------------- |
| `Alma10-202606010804.stargate-afcfa06.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.mf) | `ff5e3866e0f3ac7a1d48ecd3909fd8d1556947d44a9dd3e37110e763a27a0f9f` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>837007360 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.ova) | `9e419cbb9df885f3890ae5b3796e1f11210873a03d5f2376b88da301bf6ceb3a` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.ovf) | `b1fd8aeb3a9c9df5557aa099284eb5b2d08f9f72f9f2b54eac07cd479b577e35` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1336672256 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.qcow2) | `35cc34956a8799810ecee5181430c567716ef7abb940daa0dfe9d620ca82ccf5` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.raw) | `c834be9684ab6d579fc456daad4898ab6a3fadb5e2935f809f8fdb8a23b851d9` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>826502278 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.raw.gz) | `dd306803a0d113aaf79e291d4422cc24befd64c5e83412df82a6b0358edc571d` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.vhd) | `ef42ad616465088ff5e8602453e6d366fe3d76cc54fc278f67fc7ee6fe19ed28` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 786M /<br>823973764 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.vhd.gz) | `05611a684383e2d841e3926881d3df9b3c35fda841a642d58b369372e71262cc` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1853882368 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.vhdx) | `37c768d3dac3db361e3777a3e7453f935141fc4df6ef39588ad6337eb05cd72c` |
| `Alma10-202606010804.stargate-afcfa06.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>836996096 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606010804.stargate-afcfa06.x86_64.vmdk) | `5aa31ddfd9461747acf921a88fa6dd5449b0ed8e22698a439e2c45b5955ee064` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `cb0a06ce0a7716b442682957d82e496ffa8a0f0b7ef988f01fd8c3a6a8af020c` |

<!-- Script will replace everything BEFORE this line -->

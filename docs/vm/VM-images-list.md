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
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>251 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.mf) | `7c1df543149e64a90999f835bb2a32877fa5a6ea668c0fe42d7915ebe26a34ba` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 993M /<br>1041192960 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.ova) | `b2355e506e9efe21ba39bb85c10ea37515ed98b22be16fe5964f2256885945a1` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7682 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.ovf) | `316d242aa31bb5dc3a7d85946ce297bc4ba2a8918f655ae61641c6ae7eb4e3a9` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1678770176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.qcow2) | `7d014c4ea527bc307b67cdb6c8ef7a0b434ce624dcb0b77da6acfd871751c6ee` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 30G /<br>32212254720 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.raw) | `215df78e6c612b4737ce286aa5e30ef7ccd3180bf6f8bd1b4cea4c3e6f4fe26e` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1001M /<br>1049161905 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.raw.gz) | `e16e6e217448a20cd45a07a6876ad08704da78417768171f88bc4c1479581099` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 31G /<br>32212255232 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vhd) | `1853dac0892de1170eed143898af2f75862c9beb3d89fde4ca0a4f8c8116311d` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1010M /<br>1058161148 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vhd.gz) | `71157d97e4a05823e3f66e21286608a4eb78e15b143337dfae24475a9b63e6c4` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.2G /<br>2256535552 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vhdx) | `7d8599247f03af68347f70ae85b44011e68307a40d931f7675160389803f1ca7` |
| `Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 993M /<br>1041180160 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606211936.SGprod-v0.5.0-rc15.x86_64.vmdk) | `da54767cc41c2e45d24a0c26a5598d466da154b6c29ad0cbde5b5a1b5b737b22` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1189 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `d2fb454b979f7857f40bfb1f4dae84596ccb3ace6303915651e33989c066d7f5` |

<!-- Script will replace everything BEFORE this line -->

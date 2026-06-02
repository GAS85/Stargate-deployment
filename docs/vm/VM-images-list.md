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
| `Alma10-202606021206.stargate-4ae89bb.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.mf) | `d2ac4f80f1fbac06997bd1bae2de2221ee809f8da039a29b0846b13b9d7b79e5` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>837765120 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.ova) | `3e06889a3da1eb5d5cca2633a2bf402c31c64908decc7d95cf1f8effbae49311` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.ovf) | `e138bab6913754621585981098e70893e589f45b91894cdb1f2feb54762f2a58` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1344864256 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.qcow2) | `82fa735a9fbe188f9971065badf6a60ab1ee9d2aa8b7e16f545ec2edb4a9f69a` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.raw) | `27a4ce690db59d75d8761bcbbc517a823667173c44917288d61ecf3673200e2f` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>827325318 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.raw.gz) | `ca1e8f3e33e0368c7eefe7ab419561a73d10992baad6abbc60b58bed41198ea7` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.vhd) | `c55859170b6f4cf87454f5aab9ef10885c6834ecf64ea26b8a6b33bf935c4cb3` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>827233155 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.vhd.gz) | `7828a3e795e5824a2af76cd708e7030217effe820f659397b2a42a83368842ad` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1837105152 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.vhdx) | `14da9131e9485deef19e87c5568d2de27f51c84baead426b592b2ebcea38370b` |
| `Alma10-202606021206.stargate-4ae89bb.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>837752832 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021206.stargate-4ae89bb.x86_64.vmdk) | `ebe9aaa70f51c39b8cc3c8910fe0d48f9f7f833a20bbce5467c23cc9b06d3243` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `78c68271327e5603b0e78070d1287b0766eee05e0b0ad0c4412a8a1d4c026870` |

<!-- Script will replace everything BEFORE this line -->

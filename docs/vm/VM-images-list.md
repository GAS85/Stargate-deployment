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
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.mf) | `78d376f2d703bb7ac49e2780985870818e2b68bbd10693cc2efffd6f8a0f563e` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 965M /<br>1011189760 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.ova) | `60761a0d60610d2b95616d71bc0fbeb1421cdd1015593db87897d2a22672fb39` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.ovf) | `14b93f0987bfded8e9853ae9446b13eb1d61ab15b3264c13352428cdc2e22172` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1651769344 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.qcow2) | `a59d989e5b4fdd3252ba0dc7880889a1e105a70424f45a24580d4230d63179c1` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.raw) | `4b58925cd348d7e6bff38f1054ba39ae720e9074be7e803571872a45f7320f4f` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 953M /<br>998447793 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.raw.gz) | `b76cd246553c0af6d24c61eef1e10f13e7de6b8d51d26c9846d8de11caf41920` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vhd) | `9414540657d4896e83ca74467b4f7e9ea9bc9bc74364547310d4be4ad2f9458f` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 949M /<br>995075065 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vhd.gz) | `a80d2f271b757fc6ef118289deacdcbe864f66fbcac4bdca573685532979d4ee` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vhdx) | `c1b23e70bd03d9276e4417fd49e8acdce296046d3c21a54363a60d5f30e281a8` |
| `Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 965M /<br>1011169792 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606041345.SGpreprod-v0.4.6.x86_64.vmdk) | `41c3c2094cdeb8f2c0845712eb62fcf84da5506e15d9a730d5e1ea12823f60ac` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `67eb43b6375723180227e0e9c9777f1047848754a8cc98b211dbdf9b0d720163` |

<!-- Script will replace everything BEFORE this line -->

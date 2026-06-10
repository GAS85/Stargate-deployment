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
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 957M /<br>1002670080 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.ova) | `b1bdab677486d1ad7cb2f1aa6c26dd3c06bee701d88e2456921e5cecbf687e78` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>255 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.mf) | `0745406a08b5890581a5e3c18714a9957627f6a84bdd8e76693b8577d4875ded` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7684 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.ovf) | `132d0a187299a87f33ae5e7b25e81002b0d5d6cacdbc0f0b57d5be400a218a71` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1637220352 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.qcow2) | `47efb648f82d25bb766cdeda92ce3b57ad781a44cee787b2b8528249dc2b06c2` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.raw) | `e4747c9bffc1dbc13da09bee1fe6f08fa9c6a8d5ebe1125ac925b80640f1973f` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 945M /<br>990213754 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.raw.gz) | `f4aca0c86e9ad46ac4fe8e047808a8e55d00feb5bd39001a0d0f431dba1f5e18` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vhd) | `62bbef8e4376a690d322046908929c658df4d8c04b34daf84efc792abfc3ae4d` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 949M /<br>994776769 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vhd.gz) | `e5cfb632461799662637b3813e246747ae58bf6170d7cfa9107f3b23e03a464d` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2055208960 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vhdx) | `2a565064d3d25cf1609b751ee45eab9ad36708bd2d3090fff9d4fdf2d7d28d59` |
| `Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 957M /<br>1002657792 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606101106.SGpreprod-v0.5.0-rc1.x86_64.vmdk) | `bcdcdfd1565d673009801e2f54a02e9638ee7d9716f131f5ccd321a7388cd670` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1209 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `eddc1f4e179ee20500724b9f0d079036b7d2c7c8e9a3f32c6f6fc22807b451c1` |

<!-- Script will replace everything BEFORE this line -->

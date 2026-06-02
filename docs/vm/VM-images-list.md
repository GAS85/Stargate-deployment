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
| `Alma10-202606021316.stargate-84673f4.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.mf) | `28766ff26eb1d247f7f76a4422a7691934bfb94f003a9018cf21b0f00ee31373` |
| `Alma10-202606021316.stargate-84673f4.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 798M /<br>835880960 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.ova) | `728e94c503912c832b6422cac311ac386c86c0bbcec80fb6eb4519205e41a59d` |
| `Alma10-202606021316.stargate-84673f4.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.ovf) | `1612562408f4800dc7b69b4dc5e691252ed596e71eab6a3f42e5ceb0fcc544fd` |
| `Alma10-202606021316.stargate-84673f4.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1341784064 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.qcow2) | `dc5518f3a5b034bbbf762a536c794b3c83d06fe9f54041f515ac8897ecfd4025` |
| `Alma10-202606021316.stargate-84673f4.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.raw) | `cc5d7e9eab37e4157f3cec37d5059d3fbb9584bc3eeee12ce514f20aa924b406` |
| `Alma10-202606021316.stargate-84673f4.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 788M /<br>825458518 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.raw.gz) | `2230ae0b8de694348f133ce35aba55079de25bdfdf6ab0d2038b5bb1789644e5` |
| `Alma10-202606021316.stargate-84673f4.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.vhd) | `79b4868cdb08e52cbfd00153671f815e1264f5d992c8d0f8e524a26fa3c07140` |
| `Alma10-202606021316.stargate-84673f4.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 788M /<br>825606203 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.vhd.gz) | `6882eff711b9bf025b25ba2bf0433e186683e84e51737390f49b971aac230645` |
| `Alma10-202606021316.stargate-84673f4.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1837105152 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.vhdx) | `b6a31326175abd2cd759963601742bd7c49bc1f0fb430e144663e4663a257c33` |
| `Alma10-202606021316.stargate-84673f4.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 798M /<br>835863552 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606021316.stargate-84673f4.x86_64.vmdk) | `ae896ff2070c0b3db34c9301b598f1494c8130fa6211d750fd21e9bc4f009ce9` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `65e105787a2a9011788582661401368c8749dc78b253575323ae7a9a3ad5bca1` |

<!-- Script will replace everything BEFORE this line -->

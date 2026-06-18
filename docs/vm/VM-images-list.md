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
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>251 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.mf) | `c6d3161ed33547bdb800bf52960fe40238f2e3757c292b0927401c5f604eddce` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 967M /<br>1013606400 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.ova) | `9f55635a2b2d4279e031a114a02fb88129b789ec2c34d8f07afe0a9e53a47171` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7682 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.ovf) | `2537fefe30c7e4f76f7cbc589ab9b7060244f92fcf5bd51f94a8e1fb78849912` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1641676800 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.qcow2) | `4a83f189f341ee49ccd51c137b7e68155440c53cc144e02e52e86352df5ae17b` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 60G /<br>64424509440 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.raw) | `1a56b945c31daa66689a84b8988c2a3ad1b11e2306134a32233818895d082645` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1005M /<br>1053208900 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.raw.gz) | `58e72e76b3d0ad7b4f7ada4877814320ee54add28415ff4aa0d223b1420dea41` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 61G /<br>64424509952 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vhd) | `13e623ef46165cab30dbfff8283dc8ce4209d9d40d0689821c5717fe672e6875` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1014M /<br>1062534732 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vhd.gz) | `db3c4dfad2e41e8892609195544311b7210b5a72d2605970f44953854fc56f52` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.3G /<br>2457862144 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vhdx) | `f3f72a3aa1b5b58af196b8d11ab74a4c54ad023fb0e8d402dece89edeadef6c6` |
| `Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 967M /<br>1013590528 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606171453.SGprod-v0.5.0-rc12.x86_64.vmdk) | `fc63c24a68059476362b424b0a89bac85c314c32a9d585cbf2d10717798242ff` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1189 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `0a8f3f10d6b29ce5bf61736ee8d54bed9fae88550aa8a190e96c9de6ebc54b8a` |

<!-- Script will replace everything BEFORE this line -->

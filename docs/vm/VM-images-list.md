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
| `Alma10-202605280855.stargate-acf4e0b.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.mf) | `f33e126947bc323e360aba6af3777b1f35f9a03029641a2b8dc730fcb0c5c840` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>837457920 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.ova) | `829171e98634ce4c72157e17d6969d751f356585db02b04adbc91d09b041b64f` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.ovf) | `0445994bccdbe77c92af1775020cb4e4954da19e4762976f2ca0f05bdb0098ba` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1335492608 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.qcow2) | `57e70fc1a0df4f70bd3fe8d0ecbb1db215f73fffe8674a619d624f61b12ee909` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.raw) | `9b9d9a78de40efb5e288dd1dd9c09ecd4aa8fce5f0b97e8195880f2540ce0043` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>827008408 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.raw.gz) | `3c5f14f67bc258d7c40679365407dea43d8639276c77388eb304f30c01ff3287` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.vhd) | `52863b2525cf7f0da8ddf8b4e3e3df42c987870f2c22c8530fe1d5b46e08a867` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 786M /<br>823798666 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.vhd.gz) | `84ba18d4df3872f688668f6881fb8771ada942a84f957070dad3ae0e1f4f99d7` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.8G /<br>1837105152 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.vhdx) | `1e59f492dd227620e469f3b3fc8affb852999f7849f61c7e6db93c687f5dd5db` |
| `Alma10-202605280855.stargate-acf4e0b.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>837444608 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202605280855.stargate-acf4e0b.x86_64.vmdk) | `5ce4c45d866555048fc25432cdd23041807b35cc6938b97c57711d03dbdab363` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `65ecb07f2b10a7e3ba64e7e991acc1372d69d420a6191eb55ec3e33840a3bd54` |

<!-- Script will replace everything BEFORE this line -->

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
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.mf) | `24663aea6353f3f88df57cf43e8de5c9ed035273e0427e51e8513683e6204b3e` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 957M /<br>1003356160 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.ova) | `6c7a6b94ba304c2cc01c10dd49b99221f8a1de6efca346add7af1bef457666c3` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.ovf) | `1a216250a843fff9e33808c557ebbca8ea43c34f65d77f3d117302cf86c1d036` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1652031488 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.qcow2) | `4253faf7c482ad276e7b3fbcad27a92034f8127dd3e0bd5a86c3bcbb47bac829` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.raw) | `c20c2983580824824ddbe009a0251bb6461fa9a346bd760d019ff8d4e81a401b` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 945M /<br>990690456 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.raw.gz) | `65573257481f626048704aea729be35468be53f0d8f2a2ab9791ebbf1345c054` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vhd) | `4d819af9bda4f7b7e42d8cf49a29cffaadc5e03e77caa9833bc6b0a702d27bf7` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 945M /<br>990206252 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vhd.gz) | `f122c7f1bf02755ee6002bd7e80480685c70f6ae6f953f42e9d486e84a71e719` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vhdx) | `7764b3b3dd8e7ca18f9ef0c238086a6578d486f4fcf784ad52c8d86c80f441db` |
| `Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 957M /<br>1003341824 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081031.SGpreprod-v0.4.8.x86_64.vmdk) | `ef4a198ed1df6b41f8707a33110a30ca6ecfe668526b299048fdcc7df00b6ec1` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `b80eb6cd45fc0a27f0844083e263501754e6fbc91bb389bed1dfc838c0a6b976` |

<!-- Script will replace everything BEFORE this line -->

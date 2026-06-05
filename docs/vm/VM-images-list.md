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
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.mf) | `0a3311790dc96a6bb9a9514bc2aa592e0f4b34d19139cb6dcd709022484834a1` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 964M /<br>1010350080 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.ova) | `ccf921a48dd5f947a63d6bb76912f87c52fc444026e47929ad33dad5c7aa5525` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.ovf) | `ac04790c4707212adce68e9cf8082bdf342c745a975c79c5452d88a695a75001` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1656619008 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.qcow2) | `12bdc9482fb93bd40c764d7cc7123a3f455ed72de40dcfc2a3f13420cc5f7344` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.raw) | `21371ba6d8d7b70784bf8a553282b10f0bc75109823af4a4884ae71e16881aea` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 952M /<br>997621220 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.raw.gz) | `e04600390867b525fb4edc5bfb1700c9fb2c24bab83b95850283d6f5dc36fe7d` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vhd) | `507abbe5cacfcdc37c5f41c08ba75e38b471c7e03af12f29233a7d360866e04a` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 951M /<br>996175186 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vhd.gz) | `5da8d004fd196914a84bd64b3ac4bb38967dc1e67f8b5e874b1f8be72bd027b5` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vhdx) | `b346a0dd873f353f700f0973ea226892130b5e6a48a28840063f17b311071fbf` |
| `Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 964M /<br>1010332160 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606051243.SGpreprod-v0.4.7.x86_64.vmdk) | `56400faedc038e53093c9ea4ae6d177066325c2de8d45903b714a1a445910d1a` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `6ec88685db80ebf84f0b4eeebb8282d49ae3e736826bddfb9a5444b0080d43de` |

<!-- Script will replace everything BEFORE this line -->

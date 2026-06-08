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
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>249 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.mf) | `f9e975d2635252839ae160e0e7149cb5ee7f847d1441fd5f5ad3431f97520805` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 959M /<br>1005291520 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.ova) | `3f045400fabe2ef401ff90243792c390127d69b06de76e42c4dd54b68d8fe267` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7681 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.ovf) | `c73c653d5dd3cd8ad588962adfbf86994991a0a07070c8ebc4add0a7b8815d24` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1657602048 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.qcow2) | `3d6faad74324d6103a0dd568a203c5c40cb2b1535fc02d7d87157e3cc308f960` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.raw) | `8f1a96e92a733b62d92d728bafc7ea98399e0e55017cd010689b12193c807e2c` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 947M /<br>992666417 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.raw.gz) | `6f468719d6553ac2d3362ef9a5b850db7dd78650b086396c097e4ee2a0f3d1f1` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vhd) | `4b8d2b101e5803d3ba3796004e7f99206a2bad518ea4c0c38779b717c3da6e4b` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 951M /<br>996484392 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vhd.gz) | `dc5694cfb23cf9b15c1cd50104a7f1b78b182029370cf98598fc3e274bfa701e` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vhdx) | `c02eb7978be4fae5eccee26d0a4f62cc9d1d42cab2b07ffa8324152db73eb3ca` |
| `Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 959M /<br>1005280256 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606081501.SGpreprod-v0.4.10.x86_64.vmdk) | `3a78f825c4f4d07eeada44028be4171e204edc0b7032ffcc26a35b36c7cb6045` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1179 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `4272e4bdf3bebc1d49e391c30e54cf0dafe3a0ba4329b676338e517877484021` |

<!-- Script will replace everything BEFORE this line -->

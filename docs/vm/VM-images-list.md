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
| `Alma10-202606020828.stargate-d2a811e.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.mf) | `197d4122539be10737ba4c3104de322545b9a564fac0cc9e16ca195ae73bf19e` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>837785600 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.ova) | `5b54d5f6b25fbacfced617f092cf61954c6056e1185a1fa28198be88db57d96c` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.ovf) | `a69ff5c0c9e2baa84218d99b3cdac07e0f24f4a47d1f9941c02b263e6fdff0dc` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1337196544 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.qcow2) | `dd88f03cc92a230dc175f87bde3810b5748bb2a085a72417cfddc513e43de05f` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.raw) | `cce0b0b24d4e0eeddff4ccc88b61baa7473b9bfa94fb1687db67d7c0a2f66649` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>827317121 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.raw.gz) | `e8b32b233f1167cc0c04d6f48545da41fd6542cb0e3c1d54fce5b8821d776d38` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.vhd) | `34cb5bcd0ad40933b61e3fec95765abd6d741dbb38ab33cd3384a40e12013d37` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 788M /<br>825547783 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.vhd.gz) | `4b8116b5b0730df04bdf8a7c21695002af18e68352bf700984409483e3741e05` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.7G /<br>1820327936 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.vhdx) | `df300c21aa8ba6a780912c003aea96e25bfa6583086b42dbd0eeae008dc5fc71` |
| `Alma10-202606020828.stargate-d2a811e.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>837768192 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606020828.stargate-d2a811e.x86_64.vmdk) | `37f124ba3bd250313f8a7762ef06cd864e8baa2a66b45b21d0743b4ca080f795` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `cf2f45df7fcd06441672422a6d8d6079521e851b5f3f4f89589161b8a2fd1f9e` |

<!-- Script will replace everything BEFORE this line -->

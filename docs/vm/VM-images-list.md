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
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>267 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.mf) | `af85a77f9f0938fed2640fff865adf736bc8e9fe87c7c50db5b8be3305ffb9a2` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 961M /<br>1007022080 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.ova) | `539898d7976995fa38606dfb540ad736870016f2b677ae734568c4fc878f4ae5` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7690 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.ovf) | `e517ad4c3c61a5238295734e8b089f2abebe66e9f6b77c046a2d3ce14a03b404` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1650917376 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.qcow2) | `074d365a15367347e567b6a07237076c858143f0af9800cc06729fe176bb1c06` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.raw) | `2fdc78c93a51bae28a4aa27865137d3fe525b6f7ba0e0c7107f2784daa375445` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 949M /<br>994400686 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.raw.gz) | `0fb5f6da5a854d1c759d1ac6b7f060831ae8102d8b557d8af6786de282176924` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vhd) | `024b0dcaf06d727074fedd8aba03c9bcb3563905b199e1d2952d46040cdc6e36` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 946M /<br>991015222 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vhd.gz) | `5309d79ef1f2ad2c4eacaf03c614a85efd692aed30d012f7337b06be48f7876b` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.0G /<br>2071986176 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vhdx) | `b2f517df04ec889759a1060977ba519bae72f7772610951425fcfa490c7a921e` |
| `Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 961M /<br>1007008256 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606040840.SGprod-v.0.4.4-22-g0e152f2.x86_64.vmdk) | `b80c6de07ba756f5184925072058748b43328471045c84666860487b262b54f0` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1269 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `5241c7c1a30b88604de2216438b2bfce686018a0a1d59889969ebd19fb1c59d3` |

<!-- Script will replace everything BEFORE this line -->

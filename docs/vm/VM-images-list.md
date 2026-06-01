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
| `Alma10-202606011141.stargate-3ce54eb.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>247 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.mf) | `f7635441b455d23e11b3c55c61652c7cf8397604444908c1ff1a539af738aaa6` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 799M /<br>836915200 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.ova) | `920830d86d882df71739f7ca58fad31ac18da65262d8b405a407d7ac875c89c6` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7680 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.ovf) | `7827a13071e7024b882656a7ca90599cc1f47679cf747ac533323c056c48debd` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.3G /<br>1336213504 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.qcow2) | `33ae9ec783f0797b84c2fc25f5576e0e71f698348091cdb85264ed03d506b8c0` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 10G /<br>10737418240 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.raw) | `4e00b8f2c81af0c6d101d2caf7efb1afd18cd6eb55129779ce4394919deb633a` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 789M /<br>826413458 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.raw.gz) | `9e59bcc9247ad1288d05520f43b3ed0200b04e9519daddc0388c8eafd07134ff` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 11G /<br>10737418752 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.vhd) | `00fd7484c7a6548c5f52e4ed59556a28380181e8f0da476e759c68945c606a7b` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 786M /<br>823679177 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.vhd.gz) | `6551da7276db0375b161bd4e9b0acd9ced99946f5b017675c7944295a11805f6` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 1.7G /<br>1820327936 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.vhdx) | `aad612476f5ee34cb10bf7ff7303fd2f546421aa0d6857a67fa70f6e4be64efe` |
| `Alma10-202606011141.stargate-3ce54eb.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 799M /<br>836903424 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606011141.stargate-3ce54eb.x86_64.vmdk) | `531a514f3119adad8846a010348b4e479b741c4f940178cdf04eac9f950bd94e` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1169 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `f2cece518e3148112f04efaaddc51587520a4c7c0fbbe29f7b9df1e374233dcd` |

<!-- Script will replace everything BEFORE this line -->

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
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.ova` | ![ova](https://img.shields.io/badge/Type-ova-blue) | 1018M /<br>1066956800 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.ova) | `03bcd002a3a4a61d7d454eea9e68bc0c9764e14ea2450658b132eda4f782224a` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.mf` | ![mf](https://img.shields.io/badge/Type-mf-blue) | 4.0K /<br>279 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.mf) | `9a88ce9c6e5a6e75619e1328f91aeba6946b73d7711eafc3b05f04487bd8988c` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.ovf` | ![ovf](https://img.shields.io/badge/Type-ovf-blue) | 8.0K /<br>7696 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.ovf) | `9cab19b9af59b45ef3744cf69d1c93601d49fd777c3f4baccbc9d4ac6b658743` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.qcow2` | ![qcow2](https://img.shields.io/badge/Type-qcow2-blue) | 1.6G /<br>1708982272 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.qcow2) | `3e3c629fa9680d280df3701a616cb9ab170b61b3fa1b0b097551fe04e6203d2f` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.raw` | ![raw](https://img.shields.io/badge/Type-raw-blue) | 30G /<br>32212254720 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.raw) | `9702c513d72719ae08c569e4de2e4c826e385eaac96cca9290e7049efb8fb881` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.raw.gz` | ![raw](https://img.shields.io/badge/Type-raw-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1.1G /<br>1074794291 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.raw.gz) | `7316e5b9c8e3c09fc796e511c02fdcb07c960ccc64cfddfadd8abf5e7d0beb97` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vhd` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) | 31G /<br>32212255232 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vhd) | `24b098c5be0477b2371ff77a2d969e7e082da28b95682fce73cf9a4dddb93fd5` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vhd.gz` | ![vhd](https://img.shields.io/badge/Type-vhd-blue) ![gz](https://img.shields.io/badge/Type-gz-green) | 1.1G /<br>1083457191 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vhd.gz) | `e5eec72f2860cc6f2f2747e1245777b0e02529168502303c06cef7c2dd38fc50` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vhdx` | ![vhdx](https://img.shields.io/badge/Type-vhdx-blue) | 2.2G /<br>2290089984 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vhdx) | `afc777d70999f199b47a69632cbe5e6a369957cfcd2795b20a1f637cfd6119e3` |
| `Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vmdk` | ![vmdk](https://img.shields.io/badge/Type-vmdk-blue) | 1018M /<br>1066937856 bytes | [Download](https://images.hin.ch/vm-images/Alma10-202606191425.SGprod-v0.5.0-dozzlekeycloaktest.x86_64.vmdk) | `fa7392023518f7ef20960f84230fae4de7588d4de9bbfb1d6bcc933b0aea7cfc` |
| `SHA256SUMS` | ![Checksum](https://img.shields.io/badge/Type-SHA256_checksum-blue) | 4.0K /<br>1329 bytes | [Download](https://images.hin.ch/vm-images/SHA256SUMS) | `85a71d6e4d5c9f97f560cf10e160c8edecae639d79f490d4a64f0a2ba4d8ca93` |

<!-- Script will replace everything BEFORE this line -->

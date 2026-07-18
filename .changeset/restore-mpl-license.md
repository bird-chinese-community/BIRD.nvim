---
bump: patch
category: fixed
---

- 🐛 **修复 MPL-2.0 许可证正文与识别信息** / **Fix MPL-2.0 license text and detection**

  此前的 LICENSE 文件在标准 MPL-2.0 正文中混入了不相关条款，导致 GitHub 将仓库许可证识别为 “Other”，v1.0.13 安装包也携带了该错误正文。本版本恢复 Mozilla 发布的标准 MPL-2.0 全文，使仓库元数据和新生成的安装包一致、正确地声明 MPL-2.0。

  The previous LICENSE file mixed unrelated clauses into the MPL-2.0 text, causing GitHub to identify the repository license as “Other” and the v1.0.13 archives to carry the incorrect text. This release restores Mozilla's canonical MPL-2.0 text so repository metadata and newly generated archives consistently declare MPL-2.0.

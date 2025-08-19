# Get-ExoMailboxAccessList.ps1

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://github.com/PowerShell/PowerShell)
[![Exchange Online Management](https://img.shields.io/powershellgallery/v/ExchangeOnlineManagement?label=ExchangeOnlineManagement)](https://www.powershellgallery.com/packages/ExchangeOnlineManagement)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/junecastillote/Get-ExoMailboxAccessList/blob/main/LICENSE)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-black)](https://github.com/junecastillote/Get-ExoMailboxAccessList)

---

- [📌 Overview](#-overview)
- [✨ Features](#-features)
- [⚙️ Requirements](#️-requirements)
- [Install the Script](#install-the-script)
- [📥 Parameters](#-parameters)
- [💡 Usage Examples](#-usage-examples)
  - [1. Get mailbox access list for a single mailbox](#1-get-mailbox-access-list-for-a-single-mailbox)
  - [2. Get mailbox access list for multiple mailboxes (via pipeline)](#2-get-mailbox-access-list-for-multiple-mailboxes-via-pipeline)
  - [3. Get mailbox access list for all shared mailboxes](#3-get-mailbox-access-list-for-all-shared-mailboxes)
- [📊 Example Output](#-example-output)
- [🧑‍💻 Author](#-author)
- [📄 License](#-license)

---

## 📌 Overview

`Get-ExoMailboxAccessList.ps1` is a PowerShell script for **Exchange Online** administrators that extracts the **Full Access**, **Send As**, and **Send on Behalf** permissions assigned to mailboxes.

This script leverages the [ExchangeOnlineManagement](https://learn.microsoft.com/powershell/exchange/connect-to-exchange-online-powershell) module to retrieve mailbox access information and outputs results either to the console or to a CSV file for reporting and auditing purposes.

---

## ✨ Features

- Retrieves permissions for:
  - **Full Access**
  - **Send As**
  - **Send on Behalf**
- Works with **single mailbox**, **multiple mailboxes**, or **all mailboxes**.
- Accepts pipeline input for automation scenarios.
- Exports results to **CSV** or returns **PowerShell objects**.
- Supports **append mode** when exporting to CSV.

---

## ⚙️ Requirements

- PowerShell **5.1 or later** (or PowerShell 7+).
- [ExchangeOnlineManagement Module](https://www.powershellgallery.com/packages/ExchangeOnlineManagement) version **3.7.0** or later.

Install the module (if not already installed):

```powershell
Install-Module ExchangeOnlineManagement
```

Connect to Exchange Online before running the script:

```powershell
Connect-ExchangeOnline
```

---

## Install the Script

You can install this script from [PowerShell Gallery](https://www.powershellgallery.com/packages/Get-ExoMailboxAccesslist) by running this command.

```PowerShell
Install-Script -Name Get-ExoMailboxAccessList
```

Or you can just download the [Get-ExoMailboxAccessList.ps1](https://github.com/junecastillote/Get-ExoMailboxAccessList/blob/main/Get-ExoMailboxAccessList.ps1) script from this repository.

---

## 📥 Parameters

| Parameter        | Type   | Required | Description                                                                                                          |
| ---------------- | ------ | -------- | -------------------------------------------------------------------------------------------------------------------- |
| **MailboxId**    | String | ✅ Yes    | The identity of the mailbox (e.g., DisplayName, PrimarySmtpAddress, UPN, GUID, Alias, etc.). Accepts pipeline input. |
| **OutputCsv**    | String | ❌ No     | Path to save results as CSV. If omitted, results are only returned to the console.                                   |
| **Append**       | Switch | ❌ No     | Appends results to an existing CSV file instead of overwriting it.                                                   |
| **ReturnResult** | Switch | ❌ No     | Returns the results to the console. Enabled by default if `-OutputCsv` is not specified.                             |

---

## 💡 Usage Examples

### 1. Get mailbox access list for a single mailbox

```powershell
.\Get-ExoMailboxAccessList.ps1 -MailboxId "Adam Smith"
```

Output is displayed in the console.

---

### 2. Get mailbox access list for multiple mailboxes (via pipeline)

```powershell
"Adam Smith","Homer@poshlab.xyz" | .\Get-ExoMailboxAccessList.ps1 -OutputCsv .
esult.csv
```

Results are exported to `result.csv`.

---

### 3. Get mailbox access list for all shared mailboxes

```powershell
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited |
    .\Get-ExoMailboxAccessList.ps1 -OutputCsv .\sharedMailboxAccess.csv
```

Results are exported to `sharedMailboxAccess.csv`.

---

## 📊 Example Output

Console/CSV output will look like this:

| Mailbox    | Email                    | FullAccess       | SendAs  | SendOnBehalf     |
| ---------- | ------------------------ | ---------------- | ------- | ---------------- |
| Adam Smith | <adam.smith@contoso.com> | John Doe, Jane D | HR Team | Assistant, Admin |

---

## 🧑‍💻 Author

- **June Castillote**
- [GitHub Repository](https://github.com/junecastillote/Get-ExoMailboxAccessList)

---

## 📄 License

This project is licensed under the [MIT License](https://github.com/junecastillote/Get-ExoMailboxAccessList/blob/main/LICENSE).

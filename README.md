# TECDCN-2914 Terraform NXOS Demo

This repository contains a module for deploying VXLAN/EVPN on Cisco Nexus devices using Terraform NXOS provider. As part of the demo presented in the Technical SEminar TECDCN-2914, this demonstrates how to automate the configuration of VXLAN/EVPN on Cisco Nexus devices with a flair of Infrastructure as Code (IaC).

## Prerequisites

- Terraform installed on your local machine.
- Access to a Cisco Nexus device that supports VXLAN/EVPN.
- Cisco NXOS provider for Terraform configured.
- Basic understanding of Terraform and Cisco Nexus configurations.

## Usage

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the cloned directory:
   ```bash
   cd tecdcn-terraform
   ```
4. Initialize Terraform:
   ```bash
   terraform init
   ```
5. Review the configuration files in the data directory.
6. Apply the configuration:
   ```bash
   terraform apply
   ```
   This will prompt you to confirm the changes. Type `yes` to proceed.
7. After the deployment is complete, you can verify the VXLAN/EVPN configuration on your Nexus device.
8. To destroy the resources created by Terraform, run:
   ```bash
   terraform destroy
   ```
   Again, confirm with `yes` when prompted.
## Notes
- Ensure that you have the necessary permissions on the Nexus device to apply configurations.
- This demo is intended for educational purposes and may require adjustments based on your specific network environment.
- For any issues or contributions, please open an issue or pull request in this repository.
## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

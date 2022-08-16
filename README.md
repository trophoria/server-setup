<div id="top" />

<br />
<div align="center">
  <a href="https://github.com/trophoria">
    <img src="https://github.com/trophoria/.github/blob/main/brand/brand.png" width="500" alt="trophoria logo" />
  </a>

  <br />
  <br />

  <p align="center">
    Ansible playbook to configure a remote linux server to host an secured trophoria instance.
    <br />
    <a href="https://github.com/trophoria/trophoria-server/"><strong>« Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/trophoria/trophoria-server/issues/new?template=bug_report.md">Report Bug</a>
    ·
    <a href="https://github.com/trophoria/trophoria-server/issues/new?template=feature_request.md">Request Feature</a>
  </p>

  <p align="center">
  	<a href="https://github.com/trophoria/trophoria-server/blob/main/LICENSE" title="license">
        <img src="https://img.shields.io/github/license/trophoria/trophoria-server?style=for-the-badge" alt="license" />
    </a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#👋-getting-started">👋 Getting Started</a></li>
    <li><a href="#🔐-security-configurations">🔐 Security configurations</a></li>
    <li><a href="#👥-contributing">👥 Contributing</a></li>
    <li><a href="#🪲-issue-reporting">🪲 Issue Reporting</a></li>
    <li><a href="#🔓-license">🔓 License</a></li>
    <li><a href="#💌-contact">💌 Contact</a></li>
  </ol>
</details>


## 👋 Getting started

Welcome to trophoria! This repository contains an ansible playbook which is used to easily setup a secured remote linux server to run a whole trophoria backend.

If you want to contribute to our community projects, we advice you to fist read through our [wiki pages](https://github.com/trophoria/.github/wiki). If you for example want to learn, how we set up our development environment, you can read our [Development setup](https://github.com/trophoria/.github/wiki/2-Development-setup). This repository itself contains more useful information like pull request templates, security guidelines and so on. Make sure to read those too!

This repository contains an ansible playbook which fully automatically configures a remote linux instance. If you want to improve it, just run the `setup` script and everything needed will be installed on your system. The setup will also ask you for your environment secrets.

```bash
$ ./setup
```

If you don't want to skip through the setup every time, you can just run the playbook by it's own.

```bash
$ cd ansible
$ ansible-playbook run.yml
```

If you only want to restart all docker services, you can run this playbook.

```bash
$ cd ansible
$ ansible-playbook run-services.yml
```

<p align="right">(<a href="#top">back to top</a>)</p>

## 🔐 Security configurations

The goal of this playbook is to setup an hardened and secure linux instance to deploy multi container instances on. Therefore the following configurations are made:

- Updates the whole linux system and enables automatic security updates
- Creates a new user with passwordless sudo rights
- Sets up fail2ban to reduce to rate of incorrect auth attempts
- Sets up a strict firewall configuration to only enable http, https and ssh ports
- Custom ssh port to waste some of the attackers time :D
- Disables password login via ssh and enforces ed25519 ssh public key authentication
- Deploys every service via docker which automatically restart if closed
- Watchtower service to update all docker services automatically
- Sets up an reverse proxy via traefik to provide https only access and service routing. Every service is not open to public by default. Only traefik should route to them.

If you find a potential risk in this setup, please read the [SECURITY](./SECURITY) guides on how to contact us. We would really appreciate it.

<p align="right">(<a href="#top">back to top</a>)</p>

## 👥 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this project better, please fork the repo and create a pull request. Don't forget to give the project a star! Thanks again! But before you get started, please see the following pages first:

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Contributing Guidelines](.github/CONTRIBUTING.md)

You can also take a look at the already mentioned wiki pages to find a few guides on how to work with the repository technologies and so on. We also included a pull request template which includes a pretty large checklist of things, you should already fulfill before creating a merge request, to keep the review time as small as possible! 

<p align="right">(<a href="#top">back to top</a>)</p>

## 🪲 Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. For other related questions/support please use the official [discord server](https://discord.gg/qWPyFWkff6). More information about issue reporting contributing are found in the [Contributing](./.github/CONTRIBUTING.md) guidelines.

<p align="right">(<a href="#top">back to top</a>)</p>

## 🔓 License

All of our software is distributed under the MIT License. See the [LICENSE](./LICENSE) file for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

## 💌 Contact

If you are interested in connecting with us, don't hesitate to do so. Either write us an email to [trophoria@gmail.com](mailto:trophoria@gmail.com) or join our [community discord ](https://discord.gg/qWPyFWkff6).

<p align="right">(<a href="#top">back to top</a>)</p>

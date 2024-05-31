# Reflect Agent

[Reflect](https://reflect.run) is a regression testing platform for web applications,
which replaces manual and code-based testing with automated test runs and failure notifications.

The Reflect Agent is a networked deamon that establishes a secure tunnel
from an internal local area network back to Reflect.
This allows customers to use Reflect's cloud-based platform
to create and run tests against private, non-publicly-accessible applications.

The Reflect Agent runs as a docker container (or directly on the host) within the private network.
It establishes a [Wireguard](https://www.wireguard.com/) tunnel via Reflect's API
through which the Reflect browsers can reach applications in the private network.

## Background

Reflect is a cloud-based platform where users can instantiate browser instances and
interact with their own web applications through those cloud browsers.
From these interactions, Reflect automatically generates repeatable test cases.
Then, users can run those test cases against their applications without manual intervention.
Reflect notifies users if the test cases were succesfully performed or not.

Since Reflect's browsers run on the public Internet, the web application under test must be publicly accessible.
However, some web applications are not publicly-accessible on the Internet.
In these cases, users run the Reflect Agent to establish a secure network connection
between their environment and the Reflect platform.
This allows private web applications to be accessible, but only to Reflect's cloud browsers.

## Installation

The default installation assumes a Linux host with kernel version 5.6 or later,
which means the Wireguard network module is included in the kernel.
However, when running in `--local` mode (see below),
a Mac OS X host with the Wireguard utilities installed can also be used.

### Docker

When running the agent as a container (again, the default),
it requires Docker or Podman to be installed on the host.
Typically, the host will have a restricted network ACL as well.

The agent binds to a UDP port on the host's network interface and
establishes a websocket to the Reflect API to be notified when new browser sessions are launched in Reflect.
For each agent-based browser session in Reflect,
the agent initiates a secure connection over Wireguard.

To install the agent, you'll need `docker` installed, and then run:

```
$ ./build-agent.sh
```

NOTE: On Windows, the bash script above will likely not work.
To build the agent for Windows, run the Docker command directly:
```
docker build -t agent .
```

(In the future, Reflect may release an official container image publicly.)

### Local

Alternatively, you can run the agent directly on your host machine running Mac OS X.
In this mode, the agent runs as a collection of bash scripts,
but requires several utility program dependencies to be installed.

You can check whether the dependencies are installed using:

```
$ ./local/check-dependencies.sh
```

Most dependencies are easily installed using a package manager, such as `brew`.
However, there are installation scripts for some dependencies, such as:

```
$ ./local/install-dependency-3proxy.sh
```

## Running the Agent

To run the agent, you'll need your Reflect account API key,
which can be found on the __Settings__ page in the Reflect web UI.

Additionally, you can optionally specify the public UDP port that the agent
will bind to in order to listen for connections from Reflect cloud browsers.

Then, run the agent using the following command usage options:

```
$ ./run-agent.sh [--local] -k <reflect_api_key> [-p <public_port>]
	Runs the Reflect Agent and connects to the specified Reflect account

	--local
		Runs the agent without Docker isolation directly on the host machine.
		This requires installing several utility program dependencies.
		See the `local/check-dependency.sh` and `local/install...` scripts.
		NOTE: this mode requires 'sudo' since it modifies network interfaces.

	-k reflect_api_key
		The API key for the Reflect account

	-p public_port
		The public port on the host machine, default 10009
```

NOTE: On Windows, the bash script above will likely not work.
To run the agent for Windows, run the Docker command directly:
```
docker run --rm --cap-add net_admin -d --name agent -e ReflectApiKey=<API_KEY> -e PublicPort=10123 -p 10123:10123/udp agent
```

The agent will generate a new keypair when it launches and
register with Reflect using your account API key.
Then, it will listen for messages from the Reflect API to learn of new agent-based browser sessions
and establish a connection to the browser sessions directly.

NOTE: Reflect only supports a single agent per account.
As a result, you should not run multiple agents at once.
In all cases, the last agent to register is the only agent that Reflect recognizes.

## Stopping the Agent

To stop the agent, run:

```
$ ./stop-agent.sh
```

or, press CTRL+C to terminate the agent when you're running in `--local` mode.

## Support

For questions about using the Reflect Agent with your Reflect account,
please email us at support@reflect.run and we'll be glad to assist.

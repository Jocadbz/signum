module main

import os
import cli
import strings

fn main() {
	// Setting Useful variables
	home := os.home_dir()


	// Check if user has ccrypt installed
	if os.exists_in_system_path("ccrypt") == false {
		println("Error: You don't have ccrypt installed (or in your system path). Install it from https://ccrypt.sourceforge.net/")
		exit(1)
	}


	// Check if user created a vault
	if os.exists("${home}/.signum") == false {
		vault_init()
	}

	mut app := cli.Command{
        name: 'signum'
        description: 'Terminal-based password manager'
        version: '1.0.0'
        required_args: 1
        execute: fn (cmd cli.Command) ! {
            retrieve_password(os.args[1])
            return
        }
        commands: [
            cli.Command{
                name: 'init'
                usage: ''
				required_args: 0
                description: 'Create the password vault'
                execute: fn (cmd cli.Command) ! {
                    vault_init()
                    return
                }
            }
            cli.Command{
                name: 'create'
                usage: '<password>'
				required_args: 1
                description: 'Register a password'
                execute: fn (cmd cli.Command) ! {
                    create(os.args[2])
                    return
                }
            }
            cli.Command{
                name: 'edit'
                usage: '<password>'
				required_args: 1
                description: 'Edits a password'
                execute: fn (cmd cli.Command) ! {
                    edit(os.args[2])
                    return
                }
            }
            cli.Command{
                name: 'list'
                usage: '<password>'
				required_args: 0
                description: 'Lists your passwords'
                execute: fn (cmd cli.Command) ! {
                    list()
                    return
                }
            }
            cli.Command{
                name: 'search'
                usage: '<password>'
				required_args: 1
                description: 'Search your passwords'
                execute: fn (cmd cli.Command) ! {
                    search(os.args[2])
                    return
                }
            }
        ]
    }
    app.setup()
    app.parse(os.args)
}

fn vault_init() {
	// Setting Useful variables
	home := os.home_dir()

	if os.exists("${home}/.signum") == true {
		println("You already have a password vault")
		exit(0)
	}


	//Now let's actually do stuff
	os.mkdir("${home}/.signum") or { panic(err) }
	println("Your password vault was created!")
}

fn create(password_path string) {
	// Setting Useful variables
	home := os.home_dir()
	editor := os.getenv("EDITOR")


	os.create("${home}/.signum/${password_path}") or {
		println("Something went wrong.")
		exit(1)
	}

	if editor == "" {
		os.system("vi ${home}/.signum/${password_path}")
	} else {
		os.system("${editor} ${home}/.signum/${password_path}")
	}

	os.system("ccrypt -e -s ${home}/.signum/${password_path}")
}

fn edit(password_path string) {
	// Setting Useful variables
	home := os.home_dir()
	editor := os.getenv("EDITOR")

	if os.exists(password_path) == false {
		println("This password does not exist.")
		exit(1)
	} else {
		os.system("ccrypt -d ${home}/.signum/${password_path}")
	}

	if editor == "" {
		os.system("vi ${home}/.signum/${password_path}")
	} else {
		os.system("${editor} ${home}/.signum/${password_path}")
	}

	os.system("ccrypt -e -s ${home}/.signum/${password_path}")
}


fn list() {

	// Setting Useful variables
	home := os.home_dir()

	list := os.ls("${home}/.signum/") or { panic(err) }

	for thing in list {
		println("-- ${thing}")
	}
}


fn retrieve_password(password_path string) {
	// Setting Useful variables
	home := os.home_dir()

	os.system("ccrypt -c ${home}/.signum/${password_path}")
	println("")
}


fn search(password_path string) {

	// Setting Useful variables
	home := os.home_dir()
	mut result := []string{}

	list := os.ls("${home}/.signum/") or { panic(err) }

	for pass in list {
		queries := strings.levenshtein_distance_percentage(pass, password_path)
		if queries > 40 {
				result << pass
		}
	}

	for pkg in result {
		println("\033[34;1m\033[0m\033[1m-- ${pkg}\033[0m")
	}
}
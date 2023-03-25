<!-- Filename:      README.md -->
<!-- Author:        Jonathan Delgado -->
<!-- Description:   GitHub README -->

<!-- Header -->
<h2 align="center">Finder Session Manager (FSM)</h2>
  <p align="center">
    Session/tab manager for macOS Finder built on <a href="https://www.hammerspoon.org/">Hammerspoon</a>.
    <br />
    <br />
    Status: <em>in progress</em>
    <!-- Documentation link -->
    <!-- ·<a href="https://stochastic-thermodynamics-in-python.readthedocs.io/en/latest/"><strong>
        Documentation
    </strong></a> -->
    <!-- Notion Roadmap link -->
    ·<a href="https://otanan.notion.site/Finder-session-manager-0d5360a4a2754726897c3ad4638a502a"><strong>
        Notion Roadmap »
    </strong></a>
  </p>
</div>


<!-- Project Demo -->
https://user-images.githubusercontent.com/6320907/189829171-1e91c3e2-0feb-4e7a-aa12-0a4d899f059b.mp4

<br>

Inspired by [Workona's](https://workona.com/) tab management system and [Sublime Text's](https://www.sublimetext.com/) own [project manager](https://packagecontrol.io/packages/ProjectManager).


<!-- ## Table of contents
* [Contact](#contact)
* [Acknowledgments](#acknowledgments) -->


## Installation

1. Follow the instructions to install [Hammerspoon](https://github.com/Hammerspoon/hammerspoon)
2. Download the contents of this repo and put them inside of the Spoons folder.
3. Insert the following command into ```init.lua``` in the .hammerspoon folder:
```lua
fsm = require('Spoons/FinderSessionManager')

-- FSM Bindings --------------------------
-- Don't hide menu on focus loss
fsm.menu.hideWithUnfocus = false
fsm.start() -- start FSM
-- Show menu
hs.hotkey.bind({'ctrl', 'alt'}, 'P', fsm.show)
-- Detach session
hs.hotkey.bind({'ctrl', 'alt'}, 'O', fsm.detach)
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

FSM saves tabs automatically as Finder is being used. Explore the menu bar menu for options on saving paths to sessions and use the default keybindings to change between sessions: Ctrl + Alt + P.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

Refer to the [Notion Roadmap] for future features and the state of the project.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact
Created by [Jonathan Delgado](https://jdelgado.net/).


<p align="right">(<a href="#readme-top">back to top</a>)</p>

[Notion Roadmap]: https://otanan.notion.site/Finder-session-manager-0d5360a4a2754726897c3ad4638a502a
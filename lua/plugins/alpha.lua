return {
    'goolord/alpha-nvim',
    dependencies = {
        'echasnovski/mini.icons',
        'nvim-lua/plenary.nvim'
    },
    config = function ()
        require'alpha'.setup(require'alpha.themes.theta'.config)
        local dashboard = require'alpha.themes.dashboard'
        dashboard.section.header.val = {
[[    ______             __                                          __              ]],
[[   /      \           |  \                                        |  \             ]],
[[  |  ▓▓▓▓▓▓\ _______ _| ▓▓_    ______   ______  _______  __     __ \▓▓______ ____  ]],
[[  | ▓▓__| ▓▓/       \   ▓▓ \  /      \ /      \|       \|  \   /  \  \      \    \ ]],
[[  | ▓▓    ▓▓  ▓▓▓▓▓▓▓\▓▓▓▓▓▓ |  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\ ▓▓▓▓▓▓▓\\▓▓\ /  ▓▓ ▓▓ ▓▓▓▓▓▓\▓▓▓▓\]],
[[  | ▓▓▓▓▓▓▓▓\▓▓    \  | ▓▓ __| ▓▓   \▓▓ ▓▓  | ▓▓ ▓▓  | ▓▓ \▓▓\  ▓▓| ▓▓ ▓▓ | ▓▓ | ▓▓]],
[[  | ▓▓  | ▓▓_\▓▓▓▓▓▓\ | ▓▓|  \ ▓▓     | ▓▓__/ ▓▓ ▓▓  | ▓▓  \▓▓ ▓▓ | ▓▓ ▓▓ | ▓▓ | ▓▓]],
[[  | ▓▓  | ▓▓       ▓▓  \▓▓  ▓▓ ▓▓      \▓▓    ▓▓ ▓▓  | ▓▓   \▓▓▓  | ▓▓ ▓▓ | ▓▓ | ▓▓]],
[[   \▓▓   \▓▓\▓▓▓▓▓▓▓    \▓▓▓▓ \▓▓       \▓▓▓▓▓▓ \▓▓   \▓▓    \▓    \▓▓\▓▓  \▓▓  \▓▓]],
                                                                                 
                                                                                 
                                                                                 
        }
    end
};  

#pragma once

namespace lustice
{
    namespace resource
    {
        struct App;
    }

    inline namespace wsi
    {
        struct Window_System final
        {
            Window_System(int w, int h, char const* title);
            ~Window_System();

            void mainloop(resource::App* app);
        };
    }
}
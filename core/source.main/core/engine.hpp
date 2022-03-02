#pragma once

#include <string>

namespace lustice
{
    struct Engine_Config
    {
        std::string app_config_path{"/core/app/dummy.json"};
    };

    auto engine_start(Engine_Config config) -> void;
    auto engine_main() -> void;
    auto engine_main_with_args(int argc, char const* const* argv) -> void;
}
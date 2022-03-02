#include "engine.hpp"
#include <core/init.hpp>
#include <core/resource/app.hpp>
#include <core/wsi/window-system.hpp>

namespace lustice
{
    namespace
    {
        template <class Fn>
        auto crash_handler(Fn&& fn) -> void try
        {
            fn();
        }
        catch (std::exception const& e) {
            //util::show_error(e);
            throw;
        }
        catch (...) {
            //util::show_error_of_current_exception();
            throw;
        }

        auto engine_start_with_config(Engine_Config config) -> void
        {
            //global_config::internal::setup_global_config(std::move(config.global_config));

            // auto resolution = (
            //     config.absolute_initial_resolution.x == 0.0f || config.absolute_initial_resolution.y == 0.0f
            //     ? config.relative_initial_resolution.aspect_ratio * config.relative_initial_resolution.scale
            //     : config.absolute_initial_resolution
            // );
            // auto app_width  = int(resolution.x);
            // auto app_height = int(resolution.y);

            // std::cout
            //     << "Starting app "
            //     << config.app_config_path
            //     << " at "
            //     << app_width
            //     << "x"
            //     << app_height
            //     << "\n"
            // ;
            // std::cout.flush();

            static wsi::Window_System ws{1980, 1080, "lusticeEngine"};
            static resource::App app{};//{config.app_config_path};
            ws.mainloop(&app);
        }
    }

    auto engine_start(Engine_Config config) -> void
    {
        crash_handler([&] {
            lustice::init();
            engine_start_with_config(std::move(config));
        });
    }

    auto engine_main() -> void
    {
        crash_handler([&] {
            lustice::init();

            //auto config = util::load_config_from_file<Engine_Config>(engine_config_path);

            Engine_Config config{};
            engine_start_with_config(std::move(config));
        });
    }

    auto engine_main_with_args(int argc, char const* const* argv) -> void
    {
        crash_handler([&] {
            lustice::init();

            //auto config = util::load_config_from_file<Engine_Config>(engine_config_path);

            // TODO: parse argv via introspection and override config.
            //if (argc == 2) config.app_config_path = argv[1];

            Engine_Config config{};
            engine_start_with_config(std::move(config));
        });
    }
}
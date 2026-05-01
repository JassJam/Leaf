#include <leaf/LeafApp.hpp>

namespace leaf
{
    void LeafApp::Run()
    {
        m_App.port(APP_PORT).multithreaded().run();
    }
}

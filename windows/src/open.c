#define UNICODE
#define _UNICODE
#include <windows.h>
#include <shellapi.h>

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow) {
    int argc = 0;
    LPWSTR *argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (!argv || argc < 2) {
        if (argv) LocalFree(argv);
        return 1;
    }

    for (int i = 1; i < argc; i++) {
        // Skip literal "{hint}" if erroneously passed by Alacritty config
        if (wcscmp(argv[i], L"{hint}") == 0) {
            continue;
        }
        ShellExecuteW(NULL, L"open", argv[i], NULL, NULL, SW_SHOWNORMAL);
    }

    LocalFree(argv);
    return 0;
}

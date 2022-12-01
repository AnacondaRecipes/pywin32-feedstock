# -----------------------------------------------------------------------------
#
#  Win32 GUI test for pywin32
#  Written by Andrew Vallette
#  November 23rd, 2022
#
# -----------------------------------------------------------------------------

import win32api
import win32gui
import win32con
import sys

def main():
    classname = 'AVPyWin32Test'

    hinst = win32api.GetModuleHandle()

    wndclass = win32gui.WNDCLASS()
    wndclass.hInstance = hinst;
    wndclass.lpfnWndProc = wndProc
    wndclass.lpszClassName = classname
    wndclass.style = win32con.CS_HREDRAW | win32con.CS_VREDRAW
    wndclass.hIcon = win32gui.LoadIcon(0, win32con.IDI_APPLICATION)
    wndclass.hCursor = win32gui.LoadCursor(0, win32con.IDC_ARROW)
    wndclass.hbrBackground = win32gui.GetStockObject(win32con.WHITE_BRUSH)

    classatom = None
    classatom = win32gui.RegisterClass(wndclass)

    hwnd = win32gui.CreateWindow(
        classatom,
        'PyWin32 Test Window Title',
        win32con.WS_OVERLAPPEDWINDOW,
        win32con.CW_USEDEFAULT,
        win32con.CW_USEDEFAULT,
        win32con.CW_USEDEFAULT,
        win32con.CW_USEDEFAULT,
        0,
        0,
        hinst,
        None)

    if hwnd == win32con.NULL:
        print('CreateWindow() failed')
        sys.exit(-1)

    win32gui.ShowWindow(hwnd, win32con.SW_SHOWNORMAL)
    if win32gui.PumpMessages() != 0:
        print('Test failed')
        sys.exit(-1)

    print('CreateWindow() succeeded, exiting')
    sys.exit()

def wndProc(hWnd, msg, wParam, lParam):
    if msg == win32con.WM_WINDOWPOSCHANGED:
        win32gui.PostQuitMessage(0)
        return -1
    else:
        return win32gui.DefWindowProc(hWnd, msg, wParam, lParam)

if __name__ == '__main__':
    main()

﻿using System;
using System.Runtime.InteropServices;
using BlockingDLLProcessSpawn.Interop;

namespace BlockingDLLProcessSpawn.Library
{
    internal class Modules
    {
        public static bool CreateBlockingDllProcess(string commandLine)
        {
            bool status;
            int error;
            IntPtr lpMitigationPolicy;

            Console.WriteLine("[>] Trying to initialize STARTUPINFOEX structure.");

            if (!Helpers.GetStartupInfoEx(out STARTUPINFOEX startupInfoEx))
                return false;

            lpMitigationPolicy = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(long)));
            Marshal.WriteInt64(lpMitigationPolicy, (long)PROCESS_CREATION_MITIGATION_POLICY.BLOCK_NON_MICROSOFT_BINARIES_ALWAYS_ON);

            Console.WriteLine("[>] Trying to update thread attribute.");

            status = NativeMethods.UpdateProcThreadAttribute(
                startupInfoEx.lpAttributeList,
                0,
                (IntPtr)PROC_THREAD_ATTRIBUTES.MITIGATION_POLICY,
                lpMitigationPolicy,
                (IntPtr)Marshal.SizeOf(typeof(long)),
                IntPtr.Zero,
                IntPtr.Zero);

            if (!status)
            {
                error = Marshal.GetLastWin32Error();
                Console.WriteLine("[-] Failed to update thread attribute.");
                Console.WriteLine("    |-> {0}", Helpers.GetWin32ErrorMessage(error, false));
                Marshal.FreeHGlobal(lpMitigationPolicy);
                Marshal.FreeHGlobal(startupInfoEx.lpAttributeList);

                return false;
            }
            else
            {
                Marshal.FreeHGlobal(lpMitigationPolicy);
                Console.WriteLine("[+] Thread attribute is updated successfully.");
            }

            Console.WriteLine("[>] Trying to create a blocking DLL process.");

            status = NativeMethods.CreateProcess(
                null,
                commandLine,
                IntPtr.Zero,
                IntPtr.Zero,
                false,
                ProcessCreationFlags.EXTENDED_STARTUPINFO_PRESENT | ProcessCreationFlags.CREATE_NEW_CONSOLE,
                IntPtr.Zero,
                Environment.CurrentDirectory,
                ref startupInfoEx,
                out PROCESS_INFORMATION processInfo);
            NativeMethods.DeleteProcThreadAttributeList(startupInfoEx.lpAttributeList);

            if (!status)
            {
                error = Marshal.GetLastWin32Error();
                Console.WriteLine("[-] Failed to create a blocking DLL  process.");
                Console.WriteLine("    |-> {0}", Helpers.GetWin32ErrorMessage(error, false));

                return false;
            }
            else
            {
                Console.WriteLine("[+] Blocking DLL process is created successfully.");
                Console.WriteLine("    [*] Command Line : {0}", commandLine);
                Console.WriteLine("    [*] PID          : {0}", processInfo.dwProcessId);
                Console.WriteLine("[*] Done.");
                NativeMethods.CloseHandle(processInfo.hThread);
                NativeMethods.CloseHandle(processInfo.hProcess);

                return true;
            }
        }
    }
}

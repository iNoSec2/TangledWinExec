﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using ProcMemScan.Interop;

namespace ProcMemScan.Library
{
    using NTSTATUS = Int32;

    internal class Modules
    {
        public static bool DumpMemory(int pid, IntPtr pMemory, uint range)
        {
            IntPtr hProcess;
            var bSuccess = false;
            var outputBuilder = new StringBuilder();

            Console.WriteLine("[>] Trying to dump target process memory.");

            try
            {
                string processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            do
            {
                string addressFormat;
                string mappedFileName;
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    hProcess = IntPtr.Zero;
                    break;
                }

                addressFormat = Environment.Is64BitProcess ? "X16" : "X8";
                mappedFileName = Helpers.GetMappedImagePathName(hProcess, pMemory);
                bSuccess = Helpers.GetMemoryBasicInformation(
                    hProcess,
                    pMemory,
                    out MEMORY_BASIC_INFORMATION mbi);

                if (bSuccess)
                {
                    outputBuilder.AppendLine("[+] Got target process memory.");
                    outputBuilder.AppendFormat("    [*] BaseAddress       : 0x{0}\n", mbi.BaseAddress.ToString(addressFormat));
                    outputBuilder.AppendFormat("    [*] AllocationBase    : 0x{0}\n", mbi.AllocationBase.ToString(addressFormat));
                    outputBuilder.AppendFormat("    [*] RegionSize        : 0x{0}\n", mbi.RegionSize.ToUInt64().ToString("X"));
                    outputBuilder.AppendFormat("    [*] AllocationProtect : {0}\n", mbi.AllocationProtect.ToString());
                    outputBuilder.AppendFormat("    [*] State             : {0}\n", mbi.State.ToString());
                    outputBuilder.AppendFormat("    [*] Protect           : {0}\n", mbi.Protect.ToString());
                    outputBuilder.AppendFormat("    [*] Type              : {0}\n", mbi.Type.ToString());
                    outputBuilder.AppendFormat("    [*] Mapped File Path  : {0}\n", mappedFileName ?? "N/A");
                }
                else
                {
                    outputBuilder.AppendLine("[-] Failed to get memory information.");
                    break;
                }

                if (range > 0)
                {
                    ulong nMaxSize = mbi.RegionSize.ToUInt64() - (ulong)(pMemory.ToInt64() - mbi.BaseAddress.ToInt64());

                    if ((ulong)range > nMaxSize)
                        range = (uint)nMaxSize;
                    else if (range == 0)
                        range = (uint)nMaxSize;

                    if ((mbi.Protect == MEMORY_PROTECTION.PAGE_NOACCESS) || (mbi.Protect == MEMORY_PROTECTION.NONE))
                    {
                        outputBuilder.AppendLine("[-] Cannot access the specified page.");
                    }
                    else
                    {
                        IntPtr pBufferToRead = Helpers.ReadMemory(hProcess, pMemory, range, out uint _);

                        if (pBufferToRead == IntPtr.Zero)
                        {
                            outputBuilder.AppendLine("[-] Failed to read the specified memory.");
                        }
                        else
                        {
                            outputBuilder.AppendFormat("    [*] Hexdump (0x{0} Byte(s)):\n\n", range.ToString("X"));
                            outputBuilder.AppendFormat("{0}\n", HexDump.Dump(pBufferToRead, pMemory, range, 2));
                            Marshal.FreeHGlobal(pBufferToRead);
                        }
                    }
                }
            } while (false);

            if (hProcess != IntPtr.Zero)
                NativeMethods.NtClose(hProcess);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return bSuccess;
        }


        public static bool DumpExportItems(int pid, IntPtr pImageBase)
        {
            var bSuccess = false;
            var outputBuilder = new StringBuilder();

            Console.WriteLine("[>] Trying to dump module exports from process memory.");

            try
            {
                string processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            do
            {
                string addressFormat = (Environment.Is64BitProcess) ? "X16" : "X8";
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out IntPtr hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    break;
                }

                bSuccess = Utilities.GetRemoteModuleExports(
                    hProcess,
                    pImageBase,
                    out IMAGE_FILE_MACHINE architecture,
                    out List<IMAGE_SECTION_HEADER> sectionHeaders,
                    out string exportName,
                    out Dictionary<string, int> exports);
                NativeMethods.NtClose(hProcess);

                if (bSuccess)
                {
                    outputBuilder.AppendFormat("[+] Got {0} export(s).\n", exports.Count);
                    outputBuilder.AppendFormat("    [*] Architecture : {0}\n", architecture.ToString());
                    outputBuilder.AppendFormat("    [*] Export Name  : {0}\n", exportName);
                    
                    if (exports.Count > 0)
                    {
                        outputBuilder.AppendLine("    [*] Export Items :");

                        foreach (var section in sectionHeaders)
                        {
                            var tmpExports = new Dictionary<string, int>();

                            foreach (var entry in exports)
                            {
                                var sectionName = Helpers.GetVirtualAddressSection(sectionHeaders, (uint)entry.Value);

                                if (string.Compare(sectionName, section.Name, true) == 0)
                                    tmpExports.Add(entry.Key, entry.Value);
                            }

                            if (tmpExports.Count > 0)
                            {
                                outputBuilder.AppendFormat("        [*] {0} Section ({1} Item(s)):\n", section.Name, tmpExports.Count);

                                foreach (var entry in tmpExports)
                                {
                                    IntPtr pBuffer;

                                    if (Environment.Is64BitProcess)
                                        pBuffer = new IntPtr(pImageBase.ToInt64() + entry.Value);
                                    else
                                        pBuffer = new IntPtr(pImageBase.ToInt32() + entry.Value);

                                    outputBuilder.AppendFormat("            [*] 0x{0} : {1}\n", pBuffer.ToString(addressFormat), entry.Key);
                                }

                                outputBuilder.AppendLine();
                            }
                        }
                    }
                }
                else
                {
                    outputBuilder.AppendLine("[-] Valid PE image is not found.");
                }
            } while (false);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return bSuccess;
        }


        public static bool ExtractMemory(int pid, IntPtr pMemory, uint nRange)
        {
            IntPtr hProcess;
            IntPtr pBufferToRead = IntPtr.Zero;
            IntPtr hFile = Win32Consts.INVALID_HANDLE_VALUE;
            var outputBuilder = new StringBuilder();
            var bSuccess = false;

            try
            {
                string processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            Console.WriteLine("[>] Trying to extract target process memory.");

            do
            {
                string mappedFileName;
                ulong nMaxSize;
                int index = 0;
                string addressFormat = (IntPtr.Size == 8) ? "X16" : "X8";
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    hProcess = IntPtr.Zero;
                    break;
                }

                mappedFileName = Helpers.GetMappedImagePathName(hProcess, pMemory);
                bSuccess = Helpers.GetMemoryBasicInformation(
                    hProcess,
                    pMemory,
                    out MEMORY_BASIC_INFORMATION mbi);

                if (bSuccess)
                {
                    outputBuilder.AppendLine("[+] Got target process memory.");
                    outputBuilder.AppendFormat("    [*] BaseAddress       : 0x{0}\n", mbi.BaseAddress.ToString(addressFormat));
                    outputBuilder.AppendFormat("    [*] AllocationBase    : 0x{0}\n", mbi.AllocationBase.ToString(addressFormat));
                    outputBuilder.AppendFormat("    [*] RegionSize        : 0x{0}\n", mbi.RegionSize.ToUInt64().ToString("X"));
                    outputBuilder.AppendFormat("    [*] AllocationProtect : {0}\n", mbi.AllocationProtect.ToString());
                    outputBuilder.AppendFormat("    [*] State             : {0}\n", mbi.State.ToString());
                    outputBuilder.AppendFormat("    [*] Protect           : {0}\n", mbi.Protect.ToString());
                    outputBuilder.AppendFormat("    [*] Type              : {0}\n", mbi.Type.ToString());
                    outputBuilder.AppendFormat("    [*] Mapped File Path  : {0}\n", mappedFileName ?? "N/A");

                    nMaxSize = mbi.RegionSize.ToUInt64() - (ulong)(pMemory.ToInt64() - mbi.BaseAddress.ToInt64());

                    if ((ulong)nRange > nMaxSize)
                        nRange = (uint)nMaxSize;
                    else if (nRange == 0)
                        nRange = (uint)nMaxSize;

                    pBufferToRead = Helpers.ReadMemory(hProcess, pMemory, nRange, out uint nReturnedBytes);

                    if (pBufferToRead == IntPtr.Zero)
                    {
                        outputBuilder.AppendLine("[-] Failed to read the specified memory.");
                    }
                    else
                    {
                        string filePath;

                        if (nReturnedBytes != nRange)
                        {
                            nRange = nReturnedBytes;
                            outputBuilder.AppendFormat("[*] Failed to read all of the specified memory. Read 0x{0} bytes.",
                                nRange.ToString("X"));
                        }

                        filePath = string.Format("memory-0x{0}-0x{1}bytes.bin",
                            pMemory.ToString(addressFormat),
                            nRange.ToString("X"));
                        filePath = Path.GetFullPath(filePath);

                        while (File.Exists(filePath))
                        {
                            filePath = string.Format("memory-0x{0}-0x{1}bytes_{2}.bin",
                                pMemory.ToString(addressFormat),
                                nRange.ToString("X"),
                                index);
                            filePath = Path.GetFullPath(filePath);
                            index++;
                        }

                        outputBuilder.AppendLine("[>] Trying to export the specified memory.");
                        outputBuilder.AppendFormat("    [*] File Path : {0}\n", filePath);

                        hFile = Helpers.CreateExportFile(filePath);

                        if (hFile == Win32Consts.INVALID_HANDLE_VALUE)
                        {
                            outputBuilder.AppendLine("[-] Failed to create file.");
                            break;
                        }

                        bSuccess = Helpers.WriteDataIntoFile(hFile, pBufferToRead, nRange);

                        if (!bSuccess)
                            outputBuilder.AppendLine("[-] Failed to write data into file.");
                        else
                            outputBuilder.AppendLine("[+] Memory is extracted successfully.");
                    }
                }
                else
                {
                    outputBuilder.AppendLine("[-] Failed to get memory information.");
                }
            } while (false);

            if (pBufferToRead != IntPtr.Zero)
                Marshal.FreeHGlobal(pBufferToRead);

            if (hFile != Win32Consts.INVALID_HANDLE_VALUE)
                NativeMethods.NtClose(hFile);

            if (hProcess != IntPtr.Zero)
                NativeMethods.NtClose(hProcess);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return bSuccess;
        }


        public static bool ExtractPeImageFile(int pid, IntPtr pImageDosHeader)
        {
            IntPtr hProcess;
            IntPtr pBufferToRead = IntPtr.Zero;
            IntPtr hFile = Win32Consts.INVALID_HANDLE_VALUE;
            string addressFormat = (IntPtr.Size == 8) ? "X16" : "X8";
            var outputBuilder = new StringBuilder();
            var bSuccess = false;

            try
            {
                string processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            Console.WriteLine("[>] Trying to extract PE image file from target process memory.");

            do
            {
                string mappedFileName;
                string filePath;
                string suffixImageName;
                uint nSizeOfPeHeader;
                int index = 0;
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    hProcess = IntPtr.Zero;
                    break;
                }

                mappedFileName = Helpers.GetMappedImagePathName(hProcess, pImageDosHeader);
                bSuccess = Helpers.GetMemoryBasicInformation(
                    hProcess,
                    pImageDosHeader,
                    out MEMORY_BASIC_INFORMATION mbi);

                if (!bSuccess)
                {
                    outputBuilder.AppendLine("[-] Failed to get memory information.");
                    break;
                }

                pBufferToRead = Helpers.ReadMemory(
                    hProcess,
                    pImageDosHeader,
                    mbi.RegionSize.ToUInt32(),
                    out uint nReturnedBytes);

                if (pBufferToRead == IntPtr.Zero)
                {
                    outputBuilder.AppendLine("[-] Failed to read memory.");
                    break;
                }

                bSuccess = Helpers.IsValidPeData(
                    pBufferToRead,
                    nReturnedBytes,
                    out IMAGE_FILE_MACHINE architecture,
                    out bool _,
                    out List<IMAGE_SECTION_HEADER> sectionHeaders);

                if (!bSuccess || (sectionHeaders.Count == 0))
                {
                    outputBuilder.AppendLine("[-] The specified memory does not contain valid PE image data.");
                    break;
                }

                if (string.IsNullOrEmpty(mappedFileName))
                    suffixImageName = "Unknown";
                else
                    suffixImageName = Path.GetFileName(mappedFileName).Replace('.', '_');

                filePath = string.Format("image-0x{0}-{1}-{2}.bin",
                    pImageDosHeader.ToString(addressFormat),
                    suffixImageName,
                    architecture.ToString());
                filePath = Path.GetFullPath(filePath);

                while (File.Exists(filePath))
                {
                    filePath = string.Format("image-0x{0}-{1}-{2}_{3}.bin",
                        pImageDosHeader.ToString(addressFormat),
                        suffixImageName,
                        architecture.ToString(),
                        index);
                    filePath = Path.GetFullPath(filePath);
                    index++;
                }

                outputBuilder.AppendLine("[>] Trying to export the specified memory.");
                outputBuilder.AppendFormat("    [*] File Path          : {0}\n", filePath);
                outputBuilder.AppendFormat("    [*] Image Architecture : {0}\n", architecture.ToString());

                nSizeOfPeHeader = sectionHeaders[0].PointerToRawData;
                hFile = Helpers.CreateExportFile(filePath);

                if (hFile == Win32Consts.INVALID_HANDLE_VALUE)
                {
                    outputBuilder.AppendLine("[-] Failed to create export file.");
                    break;
                }

                bSuccess = Helpers.WriteDataIntoFile(hFile, pBufferToRead, nSizeOfPeHeader);
                Marshal.FreeHGlobal(pBufferToRead);
                pBufferToRead = IntPtr.Zero;

                if (!bSuccess)
                {
                    outputBuilder.AppendLine("[-] Failed to write data into file.");
                    break;
                }

                foreach (var section in sectionHeaders)
                {
                    IntPtr pSection;

                    if (Environment.Is64BitProcess)
                        pSection = new IntPtr(pImageDosHeader.ToInt64() + section.VirtualAddress);
                    else
                        pSection = new IntPtr(pImageDosHeader.ToInt32() + (int)section.VirtualAddress);

                    pBufferToRead = Helpers.ReadMemory(
                        hProcess,
                        pSection,
                        section.SizeOfRawData,
                        out nReturnedBytes);

                    if ((pBufferToRead == IntPtr.Zero) || (nReturnedBytes != section.SizeOfRawData))
                    {
                        outputBuilder.AppendFormat("[-] Failed to read {0} section data.\n", section.Name);
                        break;
                    }

                    bSuccess = Helpers.WriteDataIntoFile(hFile, pBufferToRead, section.SizeOfRawData);
                    Marshal.FreeHGlobal(pBufferToRead);
                    pBufferToRead = IntPtr.Zero;

                    if (!bSuccess)
                    {
                        outputBuilder.AppendLine("[-] Failed to write data into file.");
                        break;
                    }
                }

                if (bSuccess)
                    outputBuilder.AppendLine("[+] Image file is extracted successfully.");
            } while (false);

            if (pBufferToRead != IntPtr.Zero)
                Marshal.FreeHGlobal(pBufferToRead);

            if (hFile != Win32Consts.INVALID_HANDLE_VALUE)
                NativeMethods.NtClose(hFile);

            if (hProcess != IntPtr.Zero)
                NativeMethods.NtClose(hProcess);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return bSuccess;
        }


        public static bool GetProcessInformation(int pid)
        {
            IntPtr hProcess;
            var bSuccess = false;
            var outputBuilder = new StringBuilder();

            try
            {
                var processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            Console.WriteLine("[>] Trying to get target process information.");

            do
            {
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    hProcess = IntPtr.Zero;
                    break;
                }

                bSuccess = Helpers.GetPebAddress(hProcess, out IntPtr pPeb, out IntPtr pPebWow32);

                if (!bSuccess)
                {
                    outputBuilder.AppendLine("[-] Failed to get PEB address.");
                    break;
                }

                if (pPebWow32 != IntPtr.Zero)
                {
                    outputBuilder.AppendFormat("\nWOW {0}\n", Utilities.DumpPebInformation(hProcess, pPebWow32, true));
                    outputBuilder.AppendFormat("\nWOW {0}\n", Utilities.DumpPebInformation(hProcess, pPeb, false));
                }
                else
                {
                    outputBuilder.AppendFormat("\n{0}\n", Utilities.DumpPebInformation(hProcess, pPeb, false));
                }
            } while (false);

            if (hProcess != IntPtr.Zero)
                NativeMethods.NtClose(hProcess);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return bSuccess;
        }


        public static bool GetProcessMemoryInformation(int pid)
        {
            string processName;
            IntPtr hProcess;
            List<MEMORY_BASIC_INFORMATION> memoryTable;
            var outputBuilder = new StringBuilder();

            try
            {
                processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            Console.WriteLine("[>] Trying to get target process memory information.");

            do
            {
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    hProcess = IntPtr.Zero;
                    break;
                }

                memoryTable = Helpers.EnumMemoryBasicInformation(hProcess);

                if (memoryTable.Count > 0)
                {
                    outputBuilder.AppendLine("[+] Got target process memory information.\n");
                    outputBuilder.AppendLine(Utilities.DumpMemoryBasicInformation(hProcess, memoryTable));
                }
                else
                {
                    outputBuilder.AppendLine("[-] Failed to get target process memory information.");
                }
            } while (false);
            
            if (hProcess != IntPtr.Zero)
                NativeMethods.NtClose(hProcess);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return true;
        }


        public static Dictionary<int, KeyValuePair<string, string>> ScanAllProcesses()
        {
            var suspiciousProcesses = new Dictionary<int, KeyValuePair<string, string>>();

            Console.WriteLine("[>] Scanning all processes...");

            foreach (Process process in Process.GetProcesses())
            {
                bool bSuspicious;
                string processName = process.ProcessName;
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(process.Id) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out IntPtr hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                    continue;

                bSuspicious = Utilities.IsSuspiciousProcess(hProcess, out string iocString);
                NativeMethods.NtClose(hProcess);

                if (bSuspicious)
                    suspiciousProcesses.Add(process.Id, new KeyValuePair<string, string>(processName, iocString));
            }

            if (suspiciousProcesses.Count > 0)
            {
                string lineFormat;
                var columnNames = new string[] { "PID", "Process Name", "Reason" };
                var columnWidth = new int[] { 3, 12, 6 };
                var outputBuilder = new StringBuilder();

                foreach (var process in suspiciousProcesses)
                {
                    if (process.Key.ToString().Length > columnWidth[0])
                        columnWidth[0] = process.Key.ToString().Length;

                    if (process.Value.Key.Length > columnWidth[1])
                        columnWidth[1] = process.Value.Key.Length;
                }

                lineFormat = string.Format("{{0, {0}}} {{1, -{1}}} {{2}}\n", columnWidth[0], columnWidth[1]);
                outputBuilder.AppendLine("\nSUSPICIOUS PROCESSES");
                outputBuilder.AppendLine("--------------------\n");
                outputBuilder.AppendFormat(lineFormat, columnNames[0], columnNames[1], columnNames[2]);
                outputBuilder.AppendFormat(lineFormat,
                    new string('=', columnWidth[0]),
                    new string('=', columnWidth[1]),
                    new string('=', columnWidth[2]));

                foreach (var process in suspiciousProcesses)
                    outputBuilder.AppendFormat(lineFormat, process.Key, process.Value.Key, process.Value.Value);

                outputBuilder.AppendFormat("\n[!] Found {0} suspicious process(es).\n", suspiciousProcesses.Count);

                Console.Write(outputBuilder.ToString());
            }
            {
                Console.WriteLine("[*] No suspicious processes.");
            }

            return suspiciousProcesses;
        }


        public static bool ScanProcess(int pid)
        {
            bool bSuspicious = false;
            var outputBuilder = new StringBuilder();

            try
            {
                string processName = Process.GetProcessById(pid).ProcessName;
                Console.WriteLine("[*] Target process is '{0}' (PID : {1}).", processName, pid);
            }
            catch
            {
                Console.WriteLine("[-] The specified PID is not found.");
                return false;
            }

            Console.WriteLine("[>] Trying to scan target process.");

            do
            {
                var clientId = new CLIENT_ID { UniqueProcess = new IntPtr(pid) };
                var objectAttributes = new OBJECT_ATTRIBUTES
                {
                    Length = Marshal.SizeOf(typeof(OBJECT_ATTRIBUTES))
                };
                NTSTATUS ntstatus = NativeMethods.NtOpenProcess(
                    out IntPtr hProcess,
                    ACCESS_MASK.PROCESS_QUERY_LIMITED_INFORMATION | ACCESS_MASK.PROCESS_VM_READ,
                    in objectAttributes,
                    in clientId);

                if (ntstatus != Win32Consts.STATUS_SUCCESS)
                {
                    outputBuilder.AppendLine("[-] Faield to open the specified process.");
                    outputBuilder.AppendFormat("    |-> {0}\n", Helpers.GetWin32ErrorMessage(ntstatus, true));
                    break;
                }

                bSuspicious = Utilities.IsSuspiciousProcess(hProcess, out string iocString);
                NativeMethods.NtClose(hProcess);

                if (bSuspicious)
                {
                    outputBuilder.AppendLine("[!] The specified process is suspicious.");
                    outputBuilder.AppendFormat("    [*] IoC : {0}\n", iocString);
                }
                else
                {
                    outputBuilder.AppendLine("[*] The specified process seems benign.");
                }
            } while (false);

            outputBuilder.AppendLine("[*] Done.");
            Console.Write(outputBuilder.ToString());

            return bSuspicious;
        }
    }
}

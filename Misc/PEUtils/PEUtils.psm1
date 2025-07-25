Set-StrictMode -Version Latest

#
# Type Definitions
#
Add-Type -Language CSharp -TypeDefinition @"
using System;

public enum ImageHeaderMagic : ushort
{
    NT32 = 0x10B,
    NT64 = 0x20B,
    ROM = 0x107
}


public enum ImageFileMachine : ushort
{
    UNKNOWN = 0,
    I386 = 0x014C,
    R3000BE = 0x0160,
    R3000 = 0x0162,
    R4000 = 0x0166,
    R10000 = 0x0168,
    WCEMIPSV2 = 0x0169,
    ALPHA = 0x0184,
    SH3 = 0x01A2,
    SH3DSP = 0x01A3,
    SH3E = 0x01A4,
    SH4 = 0x01A6,
    SH5 = 0x01A8,
    ARM = 0x01C0,
    THUMB = 0x01C2,
    ARMNT = 0x01C4,
    AM33 = 0x01D3,
    POWERPC = 0x01F0,
    POWERPCFP = 0x01F1,
    IA64 = 0x0200,
    MIPS16 = 0x0266,
    ALPHA64 = 0x0284,
    MIPSFPU = 0x0366,
    MIPSFPU16 = 0x0466,
    AXP64 = 0x0284,
    TRICORE = 0x0520,
    CEF = 0x0CEF,
    EBC = 0x0EBC,
    RISCV32 = 0x5032,
    RISCV64 = 0x5064,
    RISCV128 = 0x5128,
    LOONGARCH32 = 0x6232,
    LOONGARCH64 = 0x6264,
    AMD64 = 0x8664,
    M32R = 0x9041,
    ARM64EC = 0xA641,
    ARM64X = 0xA64E,
    ARM64 = 0xAA64,
    CEE = 0xC0EE
}


public enum ImageSybsystemType : ushort
{
    Unknown = 0,
    Native = 1,
    WindowsGui = 2,
    WindowsCui = 3,
    Os2Cui = 5,
    PosixCui = 7,
    WindowsCeGui = 9,
    EfiApplication = 10,
    EfiBootServiceDriver = 11,
    EfiRuntimeDriver = 12,
    EfiRom = 13,
    Xbox = 14,
    WindowsBootApplication = 16
}


[Flags]
public enum ImageFileCharacteristics : ushort
{
    RelocsStripped = 0x0001,
    ExecutableImage = 0x0002,
    LineNumsStripped = 0x0004,
    LocalSymsStripped = 0x0008,
    AggresiveWsTrim = 0x0010,
    LargeAddressAware = 0x0020,
    BytesReservedLo = 0x0080,
    Machine32Bit = 0x0100,
    DebugStripped = 0x0200,
    RemovableRunFromSwap = 0x0400,
    NetRunFromSwap = 0x0800,
    System = 0x1000,
    Dll = 0x2000,
    UpSystemOnly = 0x4000,
    BytesReservedHi = 0x8000
}


[Flags]
public enum ImageCharacteristics : ushort
{
    Reserved0 = 0x0001,
    Reserved1 = 0x0002,
    Reserved2 = 0x0004,
    Reserved3 = 0x0008,
    HighEntropyVa = 0x0020,
    DynamicBase = 0x0040,
    ForceIntegrity = 0x0080,
    NxCompat = 0x0100,
    NoIsolation = 0x0200,
    NoSeh = 0x0400,
    NoBind = 0x0800,
    AppContainer = 0x1000,
    WdmDriver = 0x2000,
    GuardCf = 0x4000,
    TerminalServerAware = 0x8000
}


[Flags]
public enum GuardFlags : uint
{
    CfInstrumented = 0x00000100,
    CfwInstrumented = 0x00000200,
    CfFunctionTablePresent = 0x00000400,
    SecurityCookieUnused = 0x00000800,
    ProtectDelayloadIat = 0x00001000,
    DelayloadIatInItsOwnSection = 0x00002000,
    CfExportSuppressionInfoPresent = 0x00004000,
    CfEnableExportSuppression = 0x00008000,
    CfLongjumpTablePresent = 0x00010000,
    CfFunctionTableSizeMask = 0xF0000000
}


[Flags]
public enum SectionCharacteristics : uint
{
    NoPad = 0x00000008,
    CntCode = 0x00000020,
    CntInitializedData = 0x00000040,
    CntUninitializedData = 0x00000080,
    LnkInfo = 0x00000200,
    LnkRemove = 0x00000800,
    LnkComdat = 0x00001000,
    NoDeferSpecExc = 0x00004000,
    Gprel = 0x00008000,
    MemFarData = 0x00008000,
    MemPurgeable = 0x00020000,
    Mem16Bit = 0x00020000,
    MemLocked = 0x00040000,
    MemPreload = 0x00080000,
    Align1Bytes = 0x00100000,
    Align2Bytes = 0x00200000,
    Align4Bytes = 0x00300000,
    Align8Bytes = 0x00400000,
    Align16Bytes = 0x00500000,
    Align32Bytes = 0x00600000,
    Align64Bytes = 0x00700000,
    Align128Bytes = 0x00800000,
    Align256Bytes = 0x00900000,
    Align512Bytes = 0x00A00000,
    Align1024Bytes = 0x00B00000,
    Align2048Bytes = 0x00C00000,
    Align4096Bytes = 0x00D00000,
    Align8192Bytes = 0x00E00000,
    AlignMask = 0x00F00000,
    LnkNrelocOvfl = 0x01000000,
    MemDiscardable = 0x02000000,
    MemNotCached = 0x04000000,
    MemNotPaged = 0x08000000,
    MemShared = 0x10000000,
    MemExecute = 0x20000000,
    MemRead = 0x40000000,
    MemWrite = 0x80000000
}


[Flags]
public enum WinCertificateType : ushort
{
    X509 = 1,
    PKCS7,
    Reserved,
    TerminalServerProtocolStack
}


[Flags]
public enum HeapFlags : uint
{
    HeapNoSerialize = 0x00000001,
    HeapGenerateExceptions = 0x00000004,
    HeapCreateEnableExecute = 0x00040000
}


[Flags]
public enum LoadLibraryFlags : ushort
{
    DontResolveDllReferences = 0x0001,
    LoadLibraryAsDatafile = 0x0002,
    LoadWithAlteredSearchPath = 0x0008,
    LoadIgnoreCodeAuthzLevel = 0x0010,
    LoadLibraryAsImageResource = 0x0020,
    LoadLibraryAsDatafileExclusive = 0x0040,
    LoadLibraryRequireSignedTarget = 0x0080,
    LoadLibrarySearchDllLoadDir = 0x0100,
    LoadLibrarySearchApplicationDir = 0x0200,
    LoadLibrarySearchUserDirs = 0x0400,
    LoadLibrarySearchSystem32 = 0x0800,
    LoadLibrarySearchDefaultDirs = 0x1000,
    LoadLibrarySafeCurrentDirs = 0x2000
}


public enum DebugType
{
    Unknown = 0,
    Coff = 1,
    Codeview = 2,
    Fpo = 3,
    Misc = 4,
    Exception = 5,
    Fixup = 6,
    OmapToSrc = 7,
    OmapFromSrc = 8,
    Borland = 9,
    Reserved10 = 10,
    ClsId = 11,
    Reserved12 = 12,
    Reserved13 = 13,
    Reserved14 = 14,
    Reserved15 = 15,
    Repro = 16,
    Reserved17 = 17,
    Reserved18 = 18,
    Reserved19 = 19,
    ExDllCharacteristics = 20
}
"@

#
# Helper Functions
#
function Get-ImageDosHeader {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes
    )

    if ($FileBytes.Length -lt 0x40) {
        throw "Input data is too small."
        return $null
    }

    $magic = [System.BitConverter]::ToUInt16($FileBytes, 0)

    if ([System.BitConverter]::ToUInt16($FileBytes, 0) -ne 0x5A4D) {
        throw "Invalid DOS header magic."
        return $null
    }

    $magicString = [System.Text.Encoding]::ASCII.GetString(([System.BitConverter]::GetBytes($magic))).TrimEnd("`0")
    $returnObject = [PSCustomObject]@{
        e_magic = $magicString
        e_cblp = [System.BitConverter]::ToUInt16($FileBytes, 0x2)
        e_cp = [System.BitConverter]::ToUInt16($FileBytes, 0x4)
        e_crlc = [System.BitConverter]::ToUInt16($FileBytes, 0x6)
        e_cparhdr = [System.BitConverter]::ToUInt16($FileBytes, 0x8)
        e_minalloc = [System.BitConverter]::ToUInt16($FileBytes, 0xA)
        e_maxalloc = [System.BitConverter]::ToUInt16($FileBytes, 0xC)
        e_ss = [System.BitConverter]::ToUInt16($FileBytes, 0xE)
        e_sp = [System.BitConverter]::ToUInt16($FileBytes, 0x10)
        e_csum = [System.BitConverter]::ToUInt16($FileBytes, 0x12)
        e_ip = [System.BitConverter]::ToUInt16($FileBytes, 0x14)
        e_cs = [System.BitConverter]::ToUInt16($FileBytes, 0x16)
        e_lfarlc = [System.BitConverter]::ToUInt16($FileBytes, 0x18)
        e_ovno = [System.BitConverter]::ToUInt16($FileBytes, 0x1A)
        e_res1 = New-Object UInt16[] 4
        e_oemid = [System.BitConverter]::ToUInt16($FileBytes, 0x24)
        e_oeminfo = [System.BitConverter]::ToUInt16($FileBytes, 0x26)
        e_res2 = New-Object UInt16[] 10
        e_lfanew = [System.BitConverter]::ToUInt32($FileBytes, 0x3C)
    }

    for ($idx = 0; $idx -lt 4; $idx++) {
        $returnObject.e_res1[$idx] = [System.BitConverter]::ToUInt16($FileBytes, 0x1C + ($idx * 2))
    }

    for ($idx = 0; $idx -lt 10; $idx++) {
        $returnObject.e_res2[$idx] = [System.BitConverter]::ToUInt16($FileBytes, 0x28 + ($idx * 2))
    }

    $returnObject
}


function Get-ImageRichHeader {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [switch]$Decode
    )

    $returnObject = $null
    $e_lfanew = (Get-ImageDosHeader -FileBytes $FileBytes).e_lfanew
    $headMagic = [System.BitConverter]::ToUInt32($FileBytes, 0x80)

    for ($idx = 0x80; $idx -le ($e_lfanew - 0x8); $idx += 4) {
        $tailMagic = [System.BitConverter]::ToUInt32($FileBytes, $idx)
        $xorKey = [System.BitConverter]::ToUInt32($FileBytes, $idx + 4)
        $xorKeyHiWord = [UInt16](($xorKey -shr 16) -band 0xFFFF)
        $xorKeyLowWord = [UInt16]($xorKey -band 0xFFFF)

        if ($tailMagic -ne 0x68636952) {
            continue
        }

        if (($headMagic -bxor $xorKey) -eq 0x536E6144) {
            $tailMagicString = [System.Text.Encoding]::ASCII.GetString($FileBytes, $idx, 4).TrimEnd("`0")
            $nEntryBytes = $idx - 0x90

            if ($Decode) {
                $returnObject = [PSCustomObject]@{
                    Header = [System.Text.Encoding]::ASCII.GetString([System.BitConverter]::GetBytes($headMagic -bxor $xorKey)).TrimEnd("`0")
                    Padding = [UInt32[]]@(
                        ([System.BitConverter]::ToUInt32($FileBytes, 0x84) -bxor $xorKey),
                        ([System.BitConverter]::ToUInt32($FileBytes, 0x88) -bxor $xorKey),
                        ([System.BitConverter]::ToUInt32($FileBytes, 0x8C) -bxor $xorKey)
                    )
                }

                for ($oft = 0; $oft -lt $nEntryBytes; $oft += 8) {
                    $propName = "Entry$($oft -shr 3)"
                    $propValue = [PSCustomObject]@{
                        Version = [System.BitConverter]::ToUInt16($FileBytes, $oft + 0x90) -bxor $xorKeyLowWord
                        Id = [System.BitConverter]::ToUInt16($FileBytes, $oft + 0x92) -bxor $xorKeyHiWord
                        Count = [System.BitConverter]::ToUInt32($FileBytes, $oft + 0x94) -bxor $xorKey
                    }
                    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name $propName -Value $propValue
                }
            } else {
                $returnObject = [PSCustomObject]@{
                    Header = $headMagic
                    Padding = [UInt32[]]@(
                        [System.BitConverter]::ToUInt32($FileBytes, 0x84),
                        [System.BitConverter]::ToUInt32($FileBytes, 0x88),
                        [System.BitConverter]::ToUInt32($FileBytes, 0x8C)
                    )
                }

                for ($oft = 0; $oft -lt $nEntryBytes; $oft += 8) {
                    $propName = "Entry$($oft -shr 3)"
                    $propValue = [PSCustomObject]@{
                        Version = [System.BitConverter]::ToUInt16($FileBytes, $oft + 0x90)
                        Id = [System.BitConverter]::ToUInt16($FileBytes, $oft + 0x92)
                        Count = [System.BitConverter]::ToUInt32($FileBytes, $oft + 0x94)
                    }
                    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name $propName -Value $propValue
                }
            }

            Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "Trailer" -Value $tailMagicString
            Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "CheckSum" -Value $xorKey
            break
        }
    }

    $returnObject
}


function Get-ImageNtHeaders {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes
    )

    $e_lfanew = (Get-ImageDosHeader -FileBytes $FileBytes).e_lfanew

    if (($e_lfanew + 0xF8) -gt $FileBytes.Length) {
        throw "File size is too small."
        return $null
    }

    $magic = [ImageHeaderMagic][System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x18)

    if (($magic -eq [ImageHeaderMagic]::NT32) -or ($magic -eq [ImageHeaderMagic]::NT64)) {
        $nPeSize = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x54)
    } else {
        throw "Invalid NT header magic."
        return $null
    }

    if ($nPeSize -gt $FileBytes.Length) {
        throw "File size is too small."
        return $null
    }

    $signature = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew)

    if ($signature -ne 0x4550) {
        throw "Invalid PE magic."
        return $null
    }

    $signatureString = [System.Text.Encoding]::ASCII.GetString(([System.BitConverter]::GetBytes($signature))).TrimEnd("`0")
    $fileHeader = [PSCustomObject]@{
        Machine = [ImageFileMachine][System.BitConverter]::ToInt16($FileBytes, $e_lfanew + 0x4)
        NumberOfSections = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x6)
        TimeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x8)
        PointerToSymbolTable = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC)
        NumberOfSymbols = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x10)
        SizeOfOptionalHeader = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x14)
        Characteristics = [ImageFileCharacteristics][System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x16)
    }

    if ($magic -eq [ImageHeaderMagic]::NT64) {
        $optionalHeader = [PSCustomObject]@{
            Magic = $magic
            MajorLinkerVersion = $FileBytes[$e_lfanew + 0x1A]
            MinorLinkerVersion = $FileBytes[$e_lfanew + 0x1B]
            SizeOfCode = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x1C)
            SizeOfInitializedData = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x20)
            SizeOfUninitializedData = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x24)
            AddressOfEntryPoint = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x28)
            BaseOfCode = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x2C)
            ImageBase = [System.BitConverter]::ToUInt64($FileBytes, $e_lfanew + 0x30)
            SectionAlignment = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x38)
            FileAlignment = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x3C)
            MajorOperatingSystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x40)
            MinorOperatingSystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x42)
            MajorImageVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x44)
            MinorImageVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x46)
            MajorSubsystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x48)
            MinorSubsystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x4A)
            Win32VersionValue = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x4C)
            SizeOfImage = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x50)
            SizeOfHeaders = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x54)
            CheckSum = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x58)
            Subsystem = [ImageSybsystemType][System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x5C)
            DllCharacteristics = [ImageCharacteristics][System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x5E)
            SizeOfStackReserve = [System.BitConverter]::ToUInt64($FileBytes, $e_lfanew + 0x60)
            SizeOfStackCommit = [System.BitConverter]::ToUInt64($FileBytes, $e_lfanew + 0x68)
            SizeOfHeapReserve = [System.BitConverter]::ToUInt64($FileBytes, $e_lfanew + 0x70)
            SizeOfHeapCommit = [System.BitConverter]::ToUInt64($FileBytes, $e_lfanew + 0x78)
            LoaderFlags = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x80)
            NumberOfRvaAndSizes = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x84)
            Directory = [PSCustomObject]@{
                Export = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x88)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x8C)
                }
                Import = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x90)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x94)
                }
                Resource = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x98)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x9C)
                }
                Exception = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xA0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xA4)
                }
                Security = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xA8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xAC)
                }
                BaseReloc = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xB0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xB4)
                }
                Debug = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xB8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xBC)
                }
                Architecture = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC4)
                }
                GlobalPtr = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xCC)
                }
                Tls = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xD0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xD4)
                }
                LoadConfig = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xD8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xDC)
                }
                BoundImport = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xE0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xE4)
                }
                Iat = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xE8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xEC)
                }
                DelayImport = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xF0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xF4)
                }
                ComDescriptor = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xF8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xFC)
                }
                Reserved = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x100)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x104)
                }
            }
        }
    } else {
        $optionalHeader = [PSCustomObject]@{
            Magic = $magic
            MajorLinkerVersion = $FileBytes[$e_lfanew + 0x1A]
            MinorLinkerVersion = $FileBytes[$e_lfanew + 0x1B]
            SizeOfCode = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x1C)
            SizeOfInitializedData = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x20)
            SizeOfUninitializedData = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x24)
            AddressOfEntryPoint = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x28)
            BaseOfCode = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x2C)
            BaseOfData = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x30)
            ImageBase = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x34)
            SectionAlignment = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x38)
            FileAlignment = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x3C)
            MajorOperatingSystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x40)
            MinorOperatingSystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x42)
            MajorImageVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x44)
            MinorImageVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x46)
            MajorSubsystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x48)
            MinorSubsystemVersion = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x4A)
            Win32VersionValue = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x4C)
            SizeOfImage = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x50)
            SizeOfHeaders = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x54)
            CheckSum = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x58)
            Subsystem = [ImageSybsystemType][System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x5C)
            DllCharacteristics = [ImageCharacteristics][System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x5E)
            SizeOfStackReserve = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x60)
            SizeOfStackCommit = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x64)
            SizeOfHeapReserve = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x68)
            SizeOfHeapCommit = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x6C)
            LoaderFlags = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x70)
            NumberOfRvaAndSizes = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x74)
            Directory = [PSCustomObject]@{
                Export = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x78)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x7C)
                }
                Import = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x80)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x84)
                }
                Resource = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x88)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x8C)
                }
                Exception = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x90)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x94)
                }
                Security = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x98)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0x9C)
                }
                BaseReloc = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xA0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xA4)
                }
                Debug = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xA8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xAC)
                }
                Architecture = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xB0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xB4)
                }
                GlobalPtr = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xB8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xBC)
                }
                Tls = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC4)
                }
                LoadConfig = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xC8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xCC)
                }
                BoundImport = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xD0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xD4)
                }
                Iat = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xD8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xDC)
                }
                DelayImport = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xE0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xE4)
                }
                ComDescriptor = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xE8)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xEC)
                }
                Reserved = [PSCustomObject]@{
                    VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xF0)
                    Size = [System.BitConverter]::ToUInt32($FileBytes, $e_lfanew + 0xF4)
                }
            }
        }
    }
    
    [PSCustomObject]@{
        Signature = $signatureString
        FileHeader = $fileHeader
        OptionalHeader = $optionalHeader
    }
}


function Get-ImageSectionHeaders {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes
    )

    $e_lfanew = (Get-ImageDosHeader -FileBytes $FileBytes).e_lfanew
    $nPeHeaderSize = (Get-ImageNtHeaders -FileBytes $FileBytes).OptionalHeader.SizeOfHeaders
    $nSectionHeaderSize = 0x28
    $sectionHeaders = @()

    if ($nPeHeaderSize -gt $FileBytes.Length) {
        Write-Warning "Invalid PE header."
        return $null
    }

    $nNumberOfSections = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x6)
    $nOptionalHeaderSize = [System.BitConverter]::ToUInt16($FileBytes, $e_lfanew + 0x14)
    $nSectionOffset = $e_lfanew + 0x18 + $nOptionalHeaderSize

    for ($idx = 0; $idx -lt $nNumberOfSections; $idx++) {
        $nCurrentHeaderOffset = $nSectionOffset + ($idx * $nSectionHeaderSize)
        $headerObject = [PSCustomObject]@{
            Name = [System.Text.Encoding]::ASCII.GetString($FileBytes, $nCurrentHeaderOffset, 8).TrimEnd("`0")
            VirtualSize = [System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0x8)
            VirtualAddress = [System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0xC)
            SizeOfRawData = [System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0x10)
            PointerToRawData = [System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0x14)
            PointerToRelocations = [System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0x18)
            PointerToLinenumbers = [System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0x1C)
            NumberOfRelocations = [System.BitConverter]::ToUInt16($FileBytes, $nCurrentHeaderOffset + 0x20)
            NumberOfLinenumbers = [System.BitConverter]::ToUInt16($FileBytes, $nCurrentHeaderOffset + 0x22)
            Characteristics = [SectionCharacteristics][System.BitConverter]::ToUInt32($FileBytes, $nCurrentHeaderOffset + 0x24)
        }
        $sectionHeaders += $headerObject
    }

    $sectionHeaders
}


function Get-ExportTable {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSCustomObject]$PeFileInformation
    )

    $tableBaseVirtual = $PeFileInformation.NtHeaders.OptionalHeader.Directory.Export.VirtualAddress

    if ($tableBaseVirtual -eq 0) {
        return $null
    }

    $tableBaseRaw = $PeFileInformation.ToRawOffset($tableBaseVirtual)
    $tableSection = $PeFileInformation.SectionHeaders | ?{ $_.Name -eq $tableBaseRaw.Section }
    $delta = $tableSection.VirtualAddress - $tableSection.PointerToRawData
    $numberOfNamePointers = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 24)
    $ordinalTable = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 36)
    $namePointerTable = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 32)
    $addressTable = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 28)
    $nameOffset = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 12) - $delta
    $nameBytesCount = 0

    while ($true) {
        if ($FileBytes[$nameOffset + $nameBytesCount] -eq 0) {
            break
        } else {
            $nameBytesCount++
        }
    }

    $exportTable = [PSCustomObject]@{
        Flags = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset)
        TimeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 4)
        MajorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 8)
        MinorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 10)
        Name = [System.Text.Encoding]::ASCII.GetString($FileBytes, $nameOffset, $nameBytesCount)
        OrdinalBase = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 16)
        AddressTableEntries = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 20)
        NumberOfNamePointers = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 24)
        Exports = [PSCustomObject[]]@()
    }

    for ($oft = 0; $oft -lt $exportTable.NumberOfNamePointers; $oft++) {
        $ordinal = [System.BitConverter]::ToUInt16($FileBytes, $ordinalTable - $delta + ($oft * 2))
        $nameOffset = [System.BitConverter]::ToUInt32($FileBytes, $namePointerTable - $delta + ($oft * 4)) - $delta
        $nameBytesCount = 0

        while ($true) {
            if ($FileBytes[$nameOffset + $nameBytesCount] -eq 0) {
                break
            } else {
                $nameBytesCount++
            }
        }

        $name = [System.Text.Encoding]::ASCII.GetString($FileBytes, $nameOffset, $nameBytesCount)
        $virtualOffset = [System.BitConverter]::ToUInt32($FileBytes, $addressTable - $delta + ($ordinal * 4))
        $rawOffset = $PeFileInformation.ToRawOffset($virtualOffset)

        $exportTable.Exports += [PSCustomObject]@{
            Ordinal = $ordinal
            Section = $rawOffset.Section
            RawOffset = $rawOffset.RawOffset
            VirtualOffset = [System.BitConverter]::ToUInt32($FileBytes, $addressTable - $delta + ($ordinal * 4))
            Name = $name
        }
    }

    $exportTable
}


function Parse-ImportLookupTable {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [UInt32]$VirtualOffset,

        [Parameter(Mandatory = $false, Position = 2)]
        [UInt32]$Delta = 0,

        [switch]$Is64Bit
    )

    $lookupTable = [PSCustomObject[]]@()

    for ($oft = 0; ; $oft++) {
        if ($Is64Bit) {
            $lookupEntry = [System.BitConverter]::ToUInt64(
                $FileBytes,
                $VirtualOffset - $Delta + ($oft * 8))
            $isOrdinal = (($lookupEntry -shr 63) -band 1)
        } else {
            $lookupEntry = [System.BitConverter]::ToUInt32(
                $FileBytes,
                $VirtualOffset - $Delta + ($oft * 4))
            $isOrdinal = (($lookupEntry -shr 31) -band 1)
        }

        if ($lookupEntry -eq 0) {
            break
        }

        if ($isOrdinal) {
            $ordinal = $lookupEntry -band [UInt16]::MaxValue
            $hint = $null
            $name = $null
        } else {
            $nameOffset = ($lookupEntry -band [Int32]::MaxValue) - $Delta
            $hint = [System.BitConverter]::ToUInt16($FileBytes, $nameOffset)
            $nameBytesCount = 0
            $ordinal = $null
            $nameOffset += 2

            while ($true) {
                if ($FileBytes[$nameOffset + $nameBytesCount] -eq 0) {
                    break
                } else {
                    $nameBytesCount++
                }
            }

            $name = [System.Text.Encoding]::ASCII.GetString($FileBytes, $nameOffset, $nameBytesCount)
        }

        $lookupTable += [PSCustomObject]@{
            Ordinal = $ordinal
            Hint = $hint
            Name = $name
        }
    }

    $lookupTable
}


function Get-ImportTable {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSCustomObject]$PeFileInformation
    )

    $importDirectories = [PSCustomObject[]]@()
    $tableBaseVirtual = $PeFileInformation.NtHeaders.OptionalHeader.Directory.Import.VirtualAddress

    if ($tableBaseVirtual -eq 0) {
        return $null
    }

    $tableBaseRaw = $PeFileInformation.ToRawOffset($tableBaseVirtual)
    $tableSection = $PeFileInformation.SectionHeaders | ?{ $_.Name -eq $tableBaseRaw.Section }
    $delta = $tableSection.VirtualAddress - $tableSection.PointerToRawData
    $is64Bit = ($PeFileInformation.NtHeaders.OptionalHeader.Magic -eq [ImageHeaderMagic]::NT64)

    for ($oft = 0; ; $oft += 20) {
        $directoryBase = $tableBaseRaw.RawOffset + $oft
        $directory = [PSCustomObject]@{
            LookupTable = [System.BitConverter]::ToUInt32($FileBytes, $directoryBase)
            TimeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $directoryBase + 4)
            ForwarderChain = [System.BitConverter]::ToUInt32($FileBytes, $directoryBase + 8)
            Name = [System.BitConverter]::ToUInt32($FileBytes, $directoryBase + 12)
            AddressTable = [System.BitConverter]::ToUInt32($FileBytes, $directoryBase + 16)
        }

        if ($directory.LookupTable -eq 0) {
            break
        }

        $nameOffset = $directory.Name - $delta
        $nameBytesCount = 0
        $addressTable = [PSCustomObject[]]@()

        while ($true) {
            if ($FileBytes[$nameOffset + $nameBytesCount] -eq 0) {
                break
            } else {
                $nameBytesCount++
            }
        }

        $libraryName = [System.Text.Encoding]::ASCII.GetString($FileBytes, $nameOffset, $nameBytesCount)
        $lookupTable = Parse-ImportLookupTable -FileBytes $FileBytes -VirtualOffset $directory.LookupTable -Delta $delta -Is64Bit:$is64Bit

        $importDirectories += [PSCustomObject]@{
            Name = $libraryName
            TimeDateStamp = $directory.TimeDateStamp
            ForwarderChain = $directory.ForwarderChain
            LookupTable = $lookupTable
        }
    }

    $imports = @()

    foreach ($directory in $importDirectories) {
        foreach ($lookuptable in $directory.LookupTable) {
            $imports += [PSCustomObject]@{
                Library = $directory.Name
                Ordinal = $lookuptable.Ordinal
                Hint = $lookuptable.Hint
                Name = $lookupTable.Name
            }
        }
    }

    [PSCustomObject]@{
        Directories = $importDirectories
        Imports = $imports
    }
}


function Parse-ResourceDirectories {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [UInt32]$TableBaseRva,

        [Parameter(Mandatory = $false, Position = 2)]
        [UInt32]$BaseOffset = 0,

        [Parameter(Mandatory = $false, Position = 3)]
        [UInt32]$Delta = 0
    )

    $tableOffset = $TableBaseRva - $Delta
    $directoryOffset = $tableOffset + $BaseOffset
    $characteristics = [System.BitConverter]::ToUInt32($FileBytes, $directoryOffset)
    $timeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $directoryOffset + 4)
    $majorVersion = [System.BitConverter]::ToUInt16($FileBytes, $directoryOffset + 8)
    $minorVersion = [System.BitConverter]::ToUInt16($FileBytes, $directoryOffset + 10)
    $numberOfNameEntries = [System.BitConverter]::ToUInt16($FileBytes, $directoryOffset + 12)
    $numberOfIdEntries = [System.BitConverter]::ToUInt16($FileBytes, $directoryOffset + 14)
    $totalEntries = $numberOfNameEntries + $numberOfIdEntries
    $resourceEntries = [PSCustomObject[]]@()

    for ($idx = 0; $idx -lt $totalEntries; $idx++) {
        $resourceData = $null
        $codePage = $null
        $subDirectory = $null
        $entryOffset = $directoryOffset + 16 + ($idx * 8)
        $identifier = [System.BitConverter]::ToUInt32($FileBytes, $entryOffset)
        $dataEntryOffset = [System.BitConverter]::ToUInt32($FileBytes, $entryOffset + 4)

        if (($identifier -shr 31) -eq 1) {
            $nameOffset = $tableOffset + ($identifier -band [Int32]::MaxValue)
            $nameLength = [System.BitConverter]::ToUInt16($FileBytes, $nameOffset) * 2
            $identifier = [System.Text.Encoding]::Unicode.GetString($FileBytes, $nameOffset + 2, $nameLength)
        }

        if (($dataEntryOffset -shr 31) -eq 1) {
            $directoryBase = $dataEntryOffset -band [Int32]::MaxValue
            $subDirectory = Parse-ResourceDirectories -FileBytes $FileBytes -TableBaseRva $TableBaseRva -BaseOffset $directoryBase -Delta $Delta
        } else {
            $dataOffset = [System.BitConverter]::ToUInt32($FileBytes, $tableOffset + $dataEntryOffset) - $delta
            $dataLength = [System.BitConverter]::ToUInt32($FileBytes, $tableOffset + $dataEntryOffset + 4)
            $codePage = [System.BitConverter]::ToUInt32($FileBytes, $tableOffset + $dataEntryOffset + 8)
            $resourceData = New-Object byte[] $dataLength
            [System.Buffer]::BlockCopy($FileBytes, $dataOffset, $resourceData, 0, $dataLength)
        }

        $resourceEntries += [PSCustomObject]@{
            Identifier = $identifier
            Data = $resourceData
            CodePage = $codePage
            SubDirectory = $subDirectory
        }
    }

    [PSCustomObject]@{
        Characteristics = $characteristics
        TimeDateStamp = $timeDateStamp
        MajorVersion = $majorVersion
        MinorVersion = $minorVersion
        NumberOfNameEntries = $numberOfNameEntries
        NumberOfIdEntries = $numberOfIdEntries
        Resources = $resourceEntries
    }
}


function Get-ResourceTable {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSCustomObject]$PeFileInformation
    )

    $tableBaseVirtual = $PeFileInformation.NtHeaders.OptionalHeader.Directory.Resource.VirtualAddress

    if ($tableBaseVirtual -eq 0) {
        return $null
    }

    $tableBaseRaw = $PeFileInformation.ToRawOffset($tableBaseVirtual)
    $tableSection = $PeFileInformation.SectionHeaders | ?{ $_.Name -eq $tableBaseRaw.Section }
    $delta = $tableSection.VirtualAddress - $tableSection.PointerToRawData
    $tableOffset = $tableBaseRaw.RawOffset
    $returnObject = Parse-ResourceDirectories -FileBytes $FileBytes -TableBaseRva $tableBaseVirtual -Delta $delta

    $dumpMethod = {
        param([string]$OutputDirectory)

        $directoryPath = [System.IO.Path]::GetFullPath($OutputDirectory)

        if ([System.IO.Directory]::Exists($directoryPath)) {
            Write-Warning "`"$($directoryPath)`" already exists. Abort."
            return
        }

        try {
            [System.IO.Directory]::CreateDirectory($directoryPath) | Out-Null
            Write-Host "`"$($directoryPath)`" is created successfully."
        } catch {
            Write-Warning "Failed to create `"$($directoryPath)`". Abort."
            return
        }

        $directories = @([PSCustomObject]@{
            Parent = $directoryPath
            Object = $this
        })

        while ($true) {
            $nextDirectories = [PSCustomObject[]]@()

            foreach ($dir in $directories) {
                foreach ($rsrc in $dir.Object.Resources) {
                    if ($rsrc.Data -ne $null) {
                        $filePath = [System.IO.Path]::GetFullPath("$($dir.Parent)/$($rsrc.Identifier).bin")
                        [System.IO.File]::WriteAllBytes($filePath, $rsrc.Data)

                        Write-Host "$($filePath) is exported successfully."
                    } else {
                        $subDirectory = [System.IO.Path]::GetFullPath("$($dir.Parent)/$($rsrc.Identifier)")

                        if (-not [System.IO.Directory]::Exists($subDirectory)) {
                            [System.IO.Directory]::CreateDirectory($subDirectory) | Out-Null
                        }

                        $nextDirectories += [PSCustomObject]@{
                            Parent = $subDirectory
                            Object = $rsrc.SubDirectory
                        }
                    }
                }
            }

            if ($nextDirectories.Count -eq 0) {
                break
            } else {
                $directories = $nextDirectories
            }
        }
    }

    Add-Member -MemberType ScriptMethod -InputObject $returnObject -Name "Dump" -Value $dumpMethod
    $returnObject
}


function Get-DebugInformation {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSCustomObject]$PeFileInformation
    )

    $tableBaseVirtual = $PeFileInformation.NtHeaders.OptionalHeader.Directory.Debug.VirtualAddress
    $tableSize = $PeFileInformation.NtHeaders.OptionalHeader.Directory.Debug.Size

    if ($tableBaseVirtual -eq 0) {
        return $null
    }

    $returnObject = [PSCustomObject[]]@()
    $tlsInformation = $null
    $tableBaseRaw = $PeFileInformation.ToRawOffset($tableBaseVirtual)
    $tableSection = $PeFileInformation.SectionHeaders | ?{ $_.Name -eq $tableBaseRaw.Section }
    $delta = $tableSection.VirtualAddress - $tableSection.PointerToRawData

    for ($oft = 0; $oft -lt $tableSize; $oft += 28) {
        $returnObject += [PSCustomObject]@{
            Characteristics = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + $oft)
            TimeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 4 + $oft)
            MajorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 8 + $oft)
            MinorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 10 + $oft)
            Type = [DebugType][System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 12 + $oft)
            SizeOfData = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 16 + $oft)
            AddressOfRawData = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 20 + $oft)
            PointerToRawData = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 24 + $oft)
        }
    }

    $returnObject
}


function Get-TlsInformation {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSCustomObject]$PeFileInformation
    )

    $importAddressTable = [PSCustomObject[]]@()
    $tableBaseVirtual = $PeFileInformation.NtHeaders.OptionalHeader.Directory.Tls.VirtualAddress

    if ($tableBaseVirtual -eq 0) {
        return $null
    }

    $tlsInformation = $null
    $tableBaseRaw = $PeFileInformation.ToRawOffset($tableBaseVirtual)
    $tableSection = $PeFileInformation.SectionHeaders | ?{ $_.Name -eq $tableBaseRaw.Section }
    $delta = $tableSection.VirtualAddress - $tableSection.PointerToRawData
    $is64Bit = ($PeFileInformation.NtHeaders.OptionalHeader.Magic -eq [ImageHeaderMagic]::NT64)

    if ($is64Bit) {
        $addressOfCallbacks = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 24)
        $callbacksBaseVirtual = $addressOfCallbacks - $PeFileInformation.NtHeaders.OptionalHeader.ImageBase
        $callbacksBaseRaw = $PeFileInformation.ToRawOffset($callbacksBaseVirtual).RawOffset
        $callbacks = [UInt64[]]@()

        for ($oft = 0; ; $oft += 8) {
            $callbackAddress = [System.BitConverter]::ToUInt64($FileBytes, $callbacksBaseRaw + $oft)

            if ($callbackAddress -ne 0) {
                $callbacks += $callbackAddress
            } else {
                break
            }
        }

        $tlsInformation = [PSCustomObject]@{
            RawDataStart = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset)
            RawDataEnd = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 8)
            AddressOfIndex = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 16)
            AddressOfCallbacks = $addressOfCallbacks
            SizeOfZeroFill = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 32)
            Characteristics = [SectionCharacteristics][System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 36)
            Callbacks = $callbacks
        }
    } else {
        $addressOfCallbacks = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 12)
        $callbacksBaseVirtual = $addressOfCallbacks - $PeFileInformation.NtHeaders.OptionalHeader.ImageBase
        $callbacksBaseRaw = $PeFileInformation.ToRawOffset($callbacksBaseVirtual).RawOffset
        $callbacks = [UInt32[]]@()

        for ($oft = 0; ; $oft += 4) {
            $callbackAddress = [System.BitConverter]::ToUInt32($FileBytes, $callbacksBaseRaw + $oft)

            if ($callbackAddress -ne 0) {
                $callbacks += $callbackAddress
            } else {
                break
            }
        }

        $tlsInformation = [PSCustomObject]@{
            RawDataStart = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset)
            RawDataEnd = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 4)
            AddressOfIndex = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 8)
            AddressOfCallbacks = $addressOfCallbacks
            SizeOfZeroFill = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 16)
            Characteristics = [SectionCharacteristics][System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 20)
            Callbacks = $callbacks
        }
    }

    $tlsInformation
}


function Get-LoadConfiguration {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]]$FileBytes,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSCustomObject]$PeFileInformation
    )

    $importAddressTable = [PSCustomObject[]]@()
    $tableBaseVirtual = $PeFileInformation.NtHeaders.OptionalHeader.Directory.LoadConfig.VirtualAddress

    if ($tableBaseVirtual -eq 0) {
        return $null
    }

    $loadConfig = $null
    $tableBaseRaw = $PeFileInformation.ToRawOffset($tableBaseVirtual)
    $is64Bit = ($PeFileInformation.NtHeaders.OptionalHeader.Magic -eq [ImageHeaderMagic]::NT64)
    $propsToAdd1 = [PSCustomObject[]]@(
        @{ Name = "GuardCFCheckFunctionPointer"; Size = 8 }
        @{ Name = "GuardCFDispatchFunctionPointer"; Size = 8 }
        @{ Name = "GuardCFFunctionTable"; Size = 8 }
        @{ Name = "GuardCFFunctionCount"; Size = 8 }
        @{ Name = "GuardFlags"; Size = 4 }
    )
    $propsToAdd2 = [PSCustomObject[]]@(
        @{ Name = "GuardAddressTakenIatEntryTable"; Size = 8 }
        @{ Name = "GuardAddressTakenIatEntryCount"; Size = 8 }
        @{ Name = "GuardLongJumpTargetTable"; Size = 8 }
        @{ Name = "GuardLongJumpTargetCount"; Size = 8 }
        @{ Name = "DynamicValueRelocTable"; Size = 8 }
        @{ Name = "CHPEMetadataPointer"; Size = 8 }
        @{ Name = "GuardRFFailureRoutine"; Size = 8 }
        @{ Name = "GuardRFFailureRoutineFunctionPointer"; Size = 8 }
        @{ Name = "DynamicValueRelocTableOffset"; Size = 4 }
        @{ Name = "DynamicValueRelocTableSection"; Size = 2 }
        @{ Name = "Reserved2"; Size = 2 }
        @{ Name = "GuardRFVerifyStackPointerFunctionPointer"; Size = 8 }
        @{ Name = "HotPatchTableOffset"; Size = 4 }
        @{ Name = "Reserved3"; Size = 4 }
        @{ Name = "EnclaveConfigurationPointer"; Size = 8 }
        @{ Name = "VolatileMetadataPointer"; Size = 8 }
        @{ Name = "GuardEHContinuationTable"; Size = 8 }
        @{ Name = "GuardEHContinuationCount"; Size = 8 }
        @{ Name = "GuardXFGCheckFunctionPointer"; Size = 8 }
        @{ Name = "GuardXFGDispatchFunctionPointer"; Size = 8 }
        @{ Name = "GuardXFGTableDispatchFunctionPointer"; Size = 8 }
        @{ Name = "CastGuardOsDeterminedFailureMode"; Size = 8 }
        @{ Name = "GuardMemcpyFunctionPointer"; Size = 8 }
        @{ Name = "UmaFunctionPointers"; Size = 8 }
    )

    if ($is64Bit) {
        $propValue = 0
        $baseSize = 112
        $loadConfig = [PSCustomObject]@{
            Size = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset)
            TimeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 4)
            MajorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 8)
            MinorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 10)
            GlobalFlagsClear = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 12)
            GlobalFlagsSet = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 16)
            CriticalSectionDefaultTimeout = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 20)
            DeCommitFreeBlockThreshold = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 24)
            DeCommitTotalFreeThreshold = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 32)
            LockPrefixTable = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 40)
            MaximumAllocationSize = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 48)
            VirtualMemoryThreshold = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 56)
            ProcessAffinityMask = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 64)
            ProcessHeapFlags = [HeapFlags][System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 72)
            CSDVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 76)
            DependentLoadFlags = [LoadLibraryFlags][System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 78)
            EditList = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 80)
            SecurityCookie = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 88)
            SEHandlerTable = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 96)
            SEHandlerCount = [System.BitConverter]::ToUInt64($FileBytes, $tableBaseRaw.RawOffset + 104)
        }

        foreach ($prop in $propsToAdd1) {
            $oft = $tableBaseRaw.RawOffset + $baseSize
            $baseSize += $prop.Size

            if ($baseSize -gt $loadConfig.Size) {
                break
            }

            if ($prop.Size -eq 8) {
                $propValue = [System.BitConverter]::ToUInt64($FileBytes, $oft)
            } elseif ($prop.Size -eq 4) {
                if ($prop.Name -ieq "GuardFlags") {
                    $propValue = [GuardFlags][System.BitConverter]::ToUInt32($FileBytes, $oft)
                } else {
                    $propValue = [System.BitConverter]::ToUInt32($FileBytes, $oft)
                }
            } elseif ($prop.Size -eq 2) {
                $propValue = [System.BitConverter]::ToUInt16($FileBytes, $oft)
            }

            Add-Member -MemberType NoteProperty -InputObject $loadConfig -Name $prop.Name -Value $propValue
        }

        $oft = $tableBaseRaw.RawOffset + $baseSize
        $baseSize += 12

        if ($baseSize -le $loadConfig.Size) {
            $codeIntegrity = [PSCustomObject]@{
                Flags = [System.BitConverter]::ToUInt16($FileBytes, $oft)
                Catalog = [System.BitConverter]::ToUInt16($FileBytes, $oft + 2)
                CatalogOffset = [System.BitConverter]::ToUInt32($FileBytes, $oft + 4)
                Reserved = [System.BitConverter]::ToUInt32($FileBytes, $oft + 8)
            }

            Add-Member -MemberType NoteProperty -InputObject $loadConfig -Name "CodeIntegrity" -Value $codeIntegrity

            foreach ($prop in $propsToAdd2) {
                $oft = $tableBaseRaw.RawOffset + $baseSize
                $baseSize += $prop.Size

                if ($baseSize -gt $loadConfig.Size) {
                    break
                }

                if ($prop.Size -eq 8) {
                    $propValue = [System.BitConverter]::ToUInt64($FileBytes, $oft)
                } elseif ($prop.Size -eq 4) {
                    $propValue = [System.BitConverter]::ToUInt32($FileBytes, $oft)
                } elseif ($prop.Size -eq 2) {
                    $propValue = [System.BitConverter]::ToUInt16($FileBytes, $oft)
                }

                Add-Member -MemberType NoteProperty -InputObject $loadConfig -Name $prop.Name -Value $propValue
            }
        }
    } else {
        $propValue = 0
        $baseSize = 72
        $loadConfig = [PSCustomObject]@{
            Size = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset)
            TimeDateStamp = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 4)
            MajorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 8)
            MinorVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 10)
            GlobalFlagsClear = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 12)
            GlobalFlagsSet = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 16)
            CriticalSectionDefaultTimeout = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 20)
            DeCommitFreeBlockThreshold = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 24)
            DeCommitTotalFreeThreshold = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 28)
            LockPrefixTable = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 32)
            MaximumAllocationSize = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 36)
            VirtualMemoryThreshold = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 40)
            ProcessAffinityMask = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 44)
            ProcessHeapFlags = [HeapFlags][System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 48)
            CSDVersion = [System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 52)
            DependentLoadFlags = [LoadLibraryFlags][System.BitConverter]::ToUInt16($FileBytes, $tableBaseRaw.RawOffset + 54)
            EditList = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 56)
            SecurityCookie = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 60)
            SEHandlerTable = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 64)
            SEHandlerCount = [System.BitConverter]::ToUInt32($FileBytes, $tableBaseRaw.RawOffset + 68)
        }

        foreach ($prop in $propsToAdd1) {
            $oft = $tableBaseRaw.RawOffset + $baseSize

            if ($prop.Size -eq 8) {
                $baseSize += 4
            } else {
                $baseSize += $prop.Size
            }

            if ($baseSize -gt $loadConfig.Size) {
                break
            }

            if (($prop.Size -eq 8) -and ($prop.Size -eq 4)) {
                if ($prop.Name -ieq "GuardFlags") {
                    $propValue = [GuardFlags][System.BitConverter]::ToUInt32($FileBytes, $oft)
                } else {
                    $propValue = [System.BitConverter]::ToUInt32($FileBytes, $oft)
                }
            } elseif ($prop.Size -eq 2) {
                $propValue = [System.BitConverter]::ToUInt16($FileBytes, $oft)
            }

            Add-Member -MemberType NoteProperty -InputObject $loadConfig -Name $prop.Name -Value $propValue
        }

        $oft = $tableBaseRaw.RawOffset + $baseSize
        $baseSize += 12

        if ($baseSize -le $loadConfig.Size) {
            $codeIntegrity = [PSCustomObject]@{
                Flags = [System.BitConverter]::ToUInt16($FileBytes, $oft)
                Catalog = [System.BitConverter]::ToUInt16($FileBytes, $oft + 2)
                CatalogOffset = [System.BitConverter]::ToUInt32($FileBytes, $oft + 4)
                Reserved = [System.BitConverter]::ToUInt32($FileBytes, $oft + 8)
            }

            Add-Member -MemberType NoteProperty -InputObject $loadConfig -Name "CodeIntegrity" -Value $codeIntegrity

            foreach ($prop in $propsToAdd2) {
                $oft = $tableBaseRaw.RawOffset + $baseSize

                if ($prop.Size -eq 8) {
                    $baseSize += 4
                } else {
                    $baseSize += $prop.Size
                }

                if ($baseSize -gt $loadConfig.Size) {
                    break
                }

                if (($prop.Size -eq 8) -and ($prop.Size -eq 4)) {
                    $propValue = [System.BitConverter]::ToUInt32($FileBytes, $oft)
                } elseif ($prop.Size -eq 2) {
                    $propValue = [System.BitConverter]::ToUInt16($FileBytes, $oft)
                }

                Add-Member -MemberType NoteProperty -InputObject $loadConfig -Name $prop.Name -Value $propValue
            }
        }
    }

    $loadConfig
}


#
# Export Functions
#
function Get-PeFileInformation {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        [switch]$DecodeRichHeader
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)

    if (-not [System.IO.File]::Exists($fullPath)) {
        Write-Warning "`"$($fullPath)`" is not found."
        return $null
    }

    Write-Verbose "Analyzing PE header of `"$($fullPath)`""

    $fileBytes = [System.IO.File]::ReadAllBytes($fullPath)
    $dosHeader = Get-ImageDosHeader -FileBytes $fileBytes
    $richHeader = Get-ImageRichHeader -File $fileBytes -Decode:$DecodeRichHeader
    $ntHeaders = Get-ImageNtHeaders -FileBytes $fileBytes
    $sectionHeaders = Get-ImageSectionHeaders -FileBytes $fileBytes
    $returnObject = $null

    if ($richHeader -ne $null) {
        $returnObject = [PSCustomObject]@{
            DosHeader = $dosHeader
            RichHeader = $richHeader
            NtHeaders = $ntHeaders
            SectionHeaders = $sectionHeaders
        }
    } else {
        $returnObject = [PSCustomObject]@{
            DosHeader = $dosHeader
            NtHeaders = $ntHeaders
            SectionHeaders = $sectionHeaders
        }
    }

    #
    # Method definition
    #
    $toVirtualOffset = {
        param([UInt32]$RawOffset)

        $virtualOffsetObject = [PSCustomObject]@{
            Section = "(Out of Range)"
            VirtualOffset = $RawOffset
        }

        if ($RawOffset -lt $this.NtHeaders.OptionalHeader.SizeOfHeaders) {
            $virtualOffsetObject.Section = "(PE Header)"
        } else {
            foreach ($header in $this.SectionHeaders) {
                if (($RawOffset -ge $header.PointerToRawData) -and
                    ($RawOffset -lt ($header.PointerToRawData + $header.SizeOfRawData))) {
                    $virtualOffsetObject.Section = $header.Name
                    $virtualOffsetObject.VirtualOffset = $RawOffset - $header.PointerToRawData + $header.VirtualAddress
                    break
                }
            }
        }

        $virtualOffsetObject
    }

    $toRawOffset = {
        param([UInt32]$VirtualOffset)

        $rawOffsetObject = [PSCustomObject]@{
            Section = "(Out of Range)"
            RawOffset = $VirtualOffset
        }
        $nRawHeaderSize = $this.NtHeaders.OptionalHeader.SizeOfHeaders
        $nVirutalHeaderSize = [UInt32](($nRawHeaderSize + 0x0FFF) -band 0xFFFFF000)

        if ($VirtualOffset -lt $nVirutalHeaderSize) {
            $rawOffsetObject.Section = "(PE Header)"
        } else {
            foreach ($header in $this.SectionHeaders) {
                $nVirtualSectionSize = [UInt32](($header.VirtualSize + 0x0FFF) -band 0xFFFFF000)

                if (($VirtualOffset -ge $header.VirtualAddress) -and
                    ($VirtualOffset -lt ($header.VirtualAddress + $nVirtualSectionSize))) {
                    $rawOffsetObject.Section = $header.Name
                    $rawOffsetObject.RawOffset = $VirtualOffset - $header.VirtualAddress + $header.PointerToRawData
                    break
                }
            }
        }

        $rawOffsetObject
    }

    Add-Member -MemberType ScriptMethod -InputObject $returnObject -Name "ToVirtualOffset" -Value $toVirtualOffset
    Add-Member -MemberType ScriptMethod -InputObject $returnObject -Name "ToRawOffset" -Value $toRawOffset

    #
    # Directory analyzing procedures
    #
    Write-Verbose "Analyzing Export Directory"
    $exportTable = Get-ExportTable -FileBytes $fileBytes -PeFileInformation $returnObject
    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "ExportTable" -Value $exportTable

    Write-Verbose "Analyzing Import Directory"
    $importTable = Get-ImportTable -FileBytes $fileBytes -PeFileInformation $returnObject
    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "ImportTable" -Value $importTable

    Write-Verbose "Analyzing Resource Directory"
    $resourceTable = Get-ResourceTable -FileBytes $fileBytes -PeFileInformation $returnObject
    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "ResourceTable" -Value $resourceTable

    Write-Verbose "Analyzing Debug Directory"
    $debugTable = Get-DebugInformation -FileBytes $fileBytes -PeFileInformation $returnObject
    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "DebugTable" -Value $debugTable

    Write-Verbose "Analyzing TLS Directory"
    $tlsCallbacks = Get-TlsInformation -FileBytes $fileBytes -PeFileInformation $returnObject
    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "TlsCallbacks" -Value $tlsCallbacks

    Write-Verbose "Analyzing Load Config Directory"
    $loadConfig = Get-LoadConfiguration -FileBytes $fileBytes -PeFileInformation $returnObject
    Add-Member -MemberType NoteProperty -InputObject $returnObject -Name "LoadConfiguration" -Value $loadConfig

    $returnObject
}


function Find-DwordFromExecutable {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true,Position=1)]
        [Int32]$Value
    )

    $returnObject = @()
    $Path = [System.IO.Path]::GetFullPath($Path)
    $FileBytes = [System.IO.File]::ReadAllBytes($Path)
    $nPeHeaderSize = (Get-ImageNtHeaders -FileBytes $FileBytes).OptionalHeader.SizeOfHeaders
    $headers = Get-ImageSectionHeaders -FileBytes $FileBytes

    for ($idx = 0; $idx -le ($FileBytes.Length - 4); $idx += 4) {
        $target = [System.BitConverter]::ToInt32($FileBytes, $idx)

        if ($target -ne $Value) {
            continue
        }

        $oftObject = [PSCustomObject]@{
            RawOffset = $idx
            VirtualOffset = 0
            Section = "(UNKNOWN)"
        }

        if ($idx -lt $nPeHeaderSize) {
            $oftObject.VirtualOffset = $idx
            $oftObject.Section = "(PE Header)"
        } else {
            foreach ($header in $headers) {
                if (($idx -ge $header.PointerToRawData) -and
                    ($idx -lt ($header.PointerToRawData + $header.SizeOfRawData))) {
                    $oftObject.VirtualOffset = $idx - $header.PointerToRawData + $header.VirtualAddress
                    $oftObject.Section = $header.Name
                    break
                }
            }
        }
        
        $returnObject += $oftObject
    }

    $returnObject
}


function Find-QwordFromExecutable {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true,Position=1)]
        [Int64]$Value
    )

    $returnObject = @()
    $Path = [System.IO.Path]::GetFullPath($Path)
    $FileBytes = [System.IO.File]::ReadAllBytes($Path)
    $nPeHeaderSize = (Get-ImageNtHeaders -FileBytes $FileBytes).OptionalHeader.SizeOfHeaders
    $headers = Get-ImageSectionHeaders -FileBytes $FileBytes

    for ($idx = 0; $idx -le ($FileBytes.Length - 8); $idx += 8) {
        $target = [System.BitConverter]::ToInt64($FileBytes, $idx)

        if ($target -ne $Value) {
            continue
        }

        $oftObject = [PSCustomObject]@{
            RawOffset = $idx
            VirtualOffset = 0
            Section = "(UNKNOWN)"
        }

        if ($idx -lt $nPeHeaderSize) {
            $oftObject.VirtualOffset = $idx
            $oftObject.Section = "(PE Header)"
        } else {
            foreach ($header in $headers) {
                if (($idx -ge $header.PointerToRawData) -and
                    ($idx -lt ($header.PointerToRawData + $header.SizeOfRawData))) {
                    $oftObject.VirtualOffset = $idx - $header.PointerToRawData + $header.VirtualAddress
                    $oftObject.Section = $header.Name
                    break
                }
            }
        }
        
        $returnObject += $oftObject
    }

    $returnObject
}


function Find-StringFromExecutable {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Value
    )

    $returnObject = @()
    $Path = [System.IO.Path]::GetFullPath($Path)
    $FileBytes = [System.IO.File]::ReadAllBytes($Path)
    $nPeHeaderSize = (Get-ImageNtHeaders -FileBytes $FileBytes).OptionalHeader.SizeOfHeaders
    $headers = Get-ImageSectionHeaders -FileBytes $FileBytes
    $nAsciiRange = $FileBytes.Length - $Value.Length
    $nUnicodeRange = $FileBytes.Length - ($Value.Length * 2)
    $nAsciiStringLength = $Value.Length
    $nUnicodeStringLength = $Value.Length * 2

    for ($idx = 0; $idx -le $nAsciiRange; $idx++) {
        $asciiString = [System.Text.Encoding]::ASCII.GetString($FileBytes, $idx, $nAsciiStringLength)
        $unicodeString = $null
        $oftObject = [PSCustomObject]@{
            RawOffset = $idx
            VirtualOffset = 0
            Section = [String]::Empty
            Encoding = [String]::Empty
            Value = [String]::Empty
        }

        if ($idx -le $nUnicodeRange) {
            $unicodeString = [System.Text.Encoding]::Unicode.GetString($FileBytes, $idx, $nUnicodeStringLength)
        }

        if ([System.String]::Compare($Value, $asciiString, $true) -eq 0) {
            $oftObject.Encoding = "ASCII"
            $oftObject.Value = $asciiString
        } elseif ([System.String]::Compare($Value, $unicodeString, $true) -eq 0) {
            $oftObject.Encoding = "Unicode"
            $oftObject.Value = $unicodeString
        } else {
            continue
        }

        if ($idx -lt $nPeHeaderSize) {
            $oftObject.VirtualOffset = $idx
            $oftObject.Section = "(PE Header)"
        } else {
            foreach ($header in $headers) {
                if (($idx -ge $header.PointerToRawData) -and
                    ($idx -lt ($header.PointerToRawData + $header.SizeOfRawData))) {
                    $oftObject.VirtualOffset = $idx - $header.PointerToRawData + $header.VirtualAddress
                    $oftObject.Section = $header.Name
                    break
                }
            }
        }

        $returnObject += $oftObject
    }

    $returnObject
}

Export-ModuleMember -Function Get-PeFileInformation
Export-ModuleMember -Function Find-DwordFromExecutable
Export-ModuleMember -Function Find-QwordFromExecutable
Export-ModuleMember -Function Find-StringFromExecutable

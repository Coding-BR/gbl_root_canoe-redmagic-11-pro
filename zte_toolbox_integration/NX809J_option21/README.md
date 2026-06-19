# NX809J ZTE Toolbox Option 21 Integration

This package contains the working reconstructed payload and the ZTE Family
Toolbox BAT with menu option `21` added.

## Files

- `ABL_with_superfastboot_NX809J.efi`
  - Reconstructed gbl_root_canoe superfastboot payload.
  - Flash target in the toolbox: `efisp`.
- `patch_log_NX809J.txt`
  - Log from `patch_abl` during payload generation.
- `ZTE_Family_Toolbox_with_option_21.bat`
  - Toolbox copy with option `21` added.

## Build Input

The payload was generated from the local ZTE Toolbox ABL image:

```text
bin\res\NX809J\abl_unlock.img
```

## Payload Hash

```text
SHA256  3E4ECFA41E5FB62F80B590AD44B6768D1E82B7CF92D368267F694D8E5264637D
```

## Patch Result

The important patch stages succeeded:

```text
ADRL patch applied: 1 location(s)
Boot patches: 1
Sink patched successfully.
Saved to ./ABL.efi
```

The warning-screen patch was optional and was skipped:

```text
Warning not found
Optional warning patch skipped: warning strings not found
```

## Toolbox Option

The added option is:

```text
21.Experimental: gbl_root_canoe superfastboot payload (NX809J)
```

It uses the same EDL/9008 write path as the original toolbox option `18`:

```text
write qcedl efisp tool\Other\8e5gbl_ours\ABL_with_superfastboot_NX809J.efi
```

The original option `18` remains unchanged. Existing option `19` can still be
used to clear `efisp`.

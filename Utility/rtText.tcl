
proc pvFileTest { ValidFileName } {

  set TestFileName "out.txt"

  if {[file exists $TestFileName] == 0 } {
    return
  }

  if {[file exists $ValidFileName] == 0 } {
    # copy the test file to the valid file.
    file copy -force $TestFileName $ValidFileName
    return
  }

  if {[catch {set ch1 [open $TestFileName r]}] != 0 } {
    return
  }

  if {[catch {set ch2 [open $ValidFileName r]}] != 0 } {
    close $ch1
    return
  }

  while {1} {
    set ch1EndFlag [eof $ch1]
    set ch2EndFlag [eof $ch2]
	  
    # If both files end then they have the save text.
    if {$ch1EndFlag && $ch2EndFlag} {
      close $ch1
      close $ch2
      return
    }

    # Check for one file ending before the other.
    if {$ch1EndFlag || $ch2EndFlag} {
      close $ch1
      close $ch2
      Application SetExitStatus 1
      return
    }

    # Read a character from both files.
    set ch1Char [read $ch1 1]
    set ch2Char [read $ch2 1]
    if { $ch1Char != $ch2Char} {
      close $ch1
      close $ch2
      Application SetExitStatus 1
      return
    }
  }
  # should not get to here.
}
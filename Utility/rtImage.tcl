proc pvImageTest { ValidImageName threshold } {
    
    vtkWindowToImageFilter _temp_w2if
    _temp_w2if SetInput RenWin1

    if {[file exists $ValidImageName] == 0 } {
	if {[catch {set channel [open $ValidImageName w]}] == 0 } {
	    close $channel
	    vtkPNGWriter _temp_pngw
	    _temp_pngw SetFileName $ValidImageName
	    _temp_pngw SetInput [_temp_w2if GetOutput]
	    _temp_pngw Write
	    _temp_pngw Delete
	} else {
	    _temp_pngw Delete
	    _temp_w2if Delete 
	    Application SetExitStatus 2
	    return
	}
    }

    vtkPNGReader _temp_png
    _temp_png SetFileName $ValidImageName
    
    vtkImageDifference _temp_id
    _temp_id SetInput [_temp_w2if GetOutput]
    _temp_id SetImage [_temp_png GetOutput]
    _temp_id Update
    set imageError [_temp_id GetThresholdedError]
    set minError [_temp_id GetThresholdedError]
    
    _temp_w2if Delete 
    _temp_id Delete
    _temp_png Delete

    if { $minError > $threshold } {
	Application SetExitStatus 1
    } 

}
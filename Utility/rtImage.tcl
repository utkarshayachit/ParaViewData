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

    if { $minError > $threshold } {
        # write out the difference image in full resolution
	vtkPNGWriter _temp_pngw2
	_temp_pngw2 SetFileName $ValidImageName.diff.png
	_temp_pngw2 SetInput [_temp_id GetOutput]
	_temp_pngw2 Write 
	_temp_pngw2 Delete 

        # write out the difference image scaled and gamma adjusted
        # for the dashboard
        set _temp_size [[_temp_png GetOutput] GetDimensions]
        if { [lindex $_temp_size 1] <= 250.0} {
            set _temp_magfactor 1.0
        } else {
            set _temp_magfactor [expr 250.0 / [lindex $_temp_size 1]]
        }

	vtkImageResample _temp_shrink
        _temp_shrink SetInput [_temp_id GetOutput]
        _temp_shrink InterpolateOn
        _temp_shrink SetAxisMagnificationFactor 0 $_temp_magfactor 
        _temp_shrink SetAxisMagnificationFactor 1 $_temp_magfactor 
	
        vtkImageShiftScale _temp_gamma
        _temp_gamma SetInput [_temp_shrink GetOutput]
        _temp_gamma SetShift 0
        _temp_gamma SetScale 10
	
        vtkJPEGWriter _temp_jpegw_dashboard
        _temp_jpegw_dashboard SetFileName $ValidImageName.diff.small.jpg
        _temp_jpegw_dashboard SetInput [_temp_gamma GetOutput]
        _temp_jpegw_dashboard SetQuality 85
        _temp_jpegw_dashboard Write
	
	# write out the image that was generated
	_temp_shrink SetInput [_temp_id GetInput]
	_temp_jpegw_dashboard SetInput [_temp_shrink GetOutput]
	_temp_jpegw_dashboard SetFileName $ValidImageName.test.small.jpg
	_temp_jpegw_dashboard Write
	
	# write out the valid image that matched
	_temp_shrink SetInput [_temp_id GetImage]
	_temp_jpegw_dashboard SetInput [_temp_shrink GetOutput]
	_temp_jpegw_dashboard SetFileName $ValidImageName.small.jpg
	_temp_jpegw_dashboard Write

	puts "Failed Image Test with error: $minError"
	
	puts -nonewline "<DartMeasurement name=\"ImageError\" type=\"numeric/double\">"
	puts -nonewline "$minError"
	puts "</DartMeasurement>"
	
	puts -nonewline "<DartMeasurement name=\"BaselineImage\" type=\"text/string\">Standard</DartMeasurement>"
	
	puts -nonewline "<DartMeasurementFile name=\"TestImage\" type=\"image/jpeg\">"
	puts -nonewline "$ValidImageName.test.small.jpg"
	puts "</DartMeasurementFile>"
	
	puts -nonewline "<DartMeasurementFile name=\"DifferenceImage\" type=\"image/jpeg\">"
	puts -nonewline "$ValidImageName.diff.small.jpg"
	puts "</DartMeasurementFile>"
	
	puts -nonewline "<DartMeasurementFile name=\"ValidImage\" type=\"image/jpeg\">"
	puts -nonewline "$ValidImageName.small.jpg"
	puts "</DartMeasurementFile>"

	Application SetExitStatus 1
    } 

    _temp_id Delete
    _temp_png Delete

}
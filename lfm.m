classdef (ConstructOnLoad = true) lfm
    properties (Access = public)
        automation;
        addinbase;
        application;
        experiment;
    end
    methods
        function out = lfm(visible)
            out.addinbase = PrincetonInstruments.LightField.AddIns.AddInBase();
            out.automation = PrincetonInstruments.LightField.Automation.Automation(visible,[]);
            out.application = out.automation.LightFieldApplication;
            out.experiment = out.application.Experiment;
            
        end
    	function close(obj)
			obj.automation.Dispose();
        end
        function set(obj,setting,value)
            if obj.experiment.Exists(setting)
                if obj.experiment.IsValid(setting,value)
                    obj.experiment.SetValue(setting,value);
                end
            end
        end
        function return_value = get(obj,setting)
            if obj.experiment.Exists(setting)
                return_value = obj.experiment.GetValue(setting);
            end
        end
        function load_experiment(obj,value)
            obj.experiment.Load(value);
        end
        function set_exposure(obj,value)
            obj.set(PrincetonInstruments.LightField.AddIns.CameraSettings.ShutterTimingExposureTime,value);
        end
        function set_frames(obj,value)
            obj.set(PrincetonInstruments.LightField.AddIns.ExperimentSettings.FrameSettingsFramesToStore,value);
        end
        function data = acquire(obj)
            import System.IO.FileAccess;
            obj.experiment.Acquire();
            while obj.experiment.IsRunning
            end
            lastfile = obj.application.FileManager.GetRecentlyAcquiredFileNames.GetItem(0);
			imageset = obj.application.FileManager.OpenFile(lastfile,FileAccess.Read);
            if imageset.Regions.Length == 1
                if imageset.Frames == 1
                    frame = imageset.GetFrame(0,0);
                    data = reshape(frame.GetData().double,frame.Width,frame.Height)';
                    return;
                else
                    data = [];
                    for i = 0:imageset.Frames-1
                        frame = imageset.GetFrame(0,i);
                        data = cat(3,data,reshape(frame.GetData().double,frame.Width,frame.Height,1)');
                    end
                    return;
                end
            else
                data = cell(imageset.Regions.Length,1);
                for j = 0:imageset.Regions.Length-1
                    if imageset.Frames == 1
                        frame = imageset.GetFrame(j,0);
                        buffer = reshape(frame.GetData().double,frame.Width,frame.Height)';
                    else
                        buffer = [];
                        for i = 0:imageset.Frames-1
                            frame = imageset.GetFrame(j,i);
                            buffer = cat(3,buffer,reshape(frame.GetData().double,frame.Width,frame.Height,1)');
                        end
                    end
                    data{j+1} = buffer;
                end
            end
        end
    end
end



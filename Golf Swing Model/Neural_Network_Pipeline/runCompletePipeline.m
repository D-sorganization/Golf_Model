% runCompletePipeline.m
% Master script to run the complete golf swing neural network pipeline
% 
% This script orchestrates:
% 1. Dataset generation with randomized inputs
% 2. Neural network training
% 3. Model evaluation and testing
% 4. Generation of prediction functions

clear; clc; close all;

fprintf('=== Golf Swing Neural Network Pipeline ===\n');
fprintf('Complete pipeline execution\n\n');

%% Configuration
pipeline_config = struct();

% Pipeline phases to run
pipeline_config.run_system_verification = true;
pipeline_config.run_dataset_generation = true;
pipeline_config.run_neural_network_training = true;
pipeline_config.run_model_evaluation = true;
pipeline_config.generate_prediction_functions = true;

% Dataset generation settings
pipeline_config.dataset_config = struct();
pipeline_config.dataset_config.num_simulations = 1000;
pipeline_config.dataset_config.simulation_duration = 5;
pipeline_config.dataset_config.sample_rate = 1000;

% Neural network settings
pipeline_config.nn_config = struct();
pipeline_config.nn_config.hidden_layers = [256, 128, 64];
pipeline_config.nn_config.learning_rate = 0.001;
pipeline_config.nn_config.batch_size = 32;
pipeline_config.nn_config.max_epochs = 100;

% Output settings
pipeline_config.save_results = true;
pipeline_config.create_plots = true;
pipeline_config.generate_report = true;

fprintf('Pipeline Configuration:\n');
fprintf('  System verification: %s\n', mat2str(pipeline_config.run_system_verification));
fprintf('  Dataset generation: %s\n', mat2str(pipeline_config.run_dataset_generation));
fprintf('  Neural network training: %s\n', mat2str(pipeline_config.run_neural_network_training));
fprintf('  Model evaluation: %s\n', mat2str(pipeline_config.run_model_evaluation));
fprintf('  Prediction functions: %s\n', mat2str(pipeline_config.generate_prediction_functions));

%% Phase 0: System Verification
if pipeline_config.run_system_verification
    fprintf('\n=== Phase 0: System Verification ===\n');
    
    try
        % Run comprehensive signal verification
        [verification_results, test_dataset] = verifySimscapeSignals(model_name, true);
        
        if strcmp(verification_results.overall_status, 'PASSED')
            fprintf('✓ System verification completed successfully\n');
        else
            fprintf('✗ System verification failed\n');
            fprintf('Please check the verification results and fix any issues before proceeding.\n');
            
            if pipeline_config.run_dataset_generation
                response = input('Continue with dataset generation anyway? (y/n): ', 's');
                if ~strcmpi(response, 'y')
                    fprintf('Pipeline stopped by user\n');
                    return;
                end
            end
        end
        
    catch ME
        fprintf('✗ System verification failed: %s\n', ME.message);
        fprintf('Error details: %s\n', getReport(ME, 'extended'));
        
        if pipeline_config.run_dataset_generation
            response = input('Continue with dataset generation anyway? (y/n): ', 's');
            if ~strcmpi(response, 'y')
                fprintf('Pipeline stopped by user\n');
                return;
            end
        end
    end
end

%% Phase 1: Dataset Generation
if pipeline_config.run_dataset_generation
    fprintf('\n=== Phase 1: Dataset Generation ===\n');
    
    try
        % Estimate time requirements
        fprintf('Estimating time requirements...\n');
        simulationTimeEstimator;
        
        % Generate dataset
        fprintf('\nStarting dataset generation...\n');
        generateCompleteDataset;
        
        fprintf('✓ Dataset generation completed successfully\n');
        
    catch ME
        fprintf('✗ Dataset generation failed: %s\n', ME.message);
        fprintf('Error details: %s\n', getReport(ME, 'extended'));
        
        if pipeline_config.run_neural_network_training
            fprintf('\nWarning: Neural network training may fail without dataset\n');
            response = input('Continue with neural network training? (y/n): ', 's');
            if ~strcmpi(response, 'y')
                fprintf('Pipeline stopped by user\n');
                return;
            end
        end
    end
end

%% Phase 2: Neural Network Training
if pipeline_config.run_neural_network_training
    fprintf('\n=== Phase 2: Neural Network Training ===\n');
    
    try
        % Check if dataset exists
        dataset_files = dir('golf_swing_dataset_*.mat');
        if isempty(dataset_files)
            fprintf('✗ No dataset files found. Please run dataset generation first.\n');
            return;
        end
        
        % Find most recent dataset
        [~, idx] = max([dataset_files.datenum]);
        dataset_path = dataset_files(idx).name;
        fprintf('Using dataset: %s\n', dataset_path);
        
        % Train neural network
        fprintf('Starting neural network training...\n');
        trainKinematicsToPolynomialMap;
        
        fprintf('✓ Neural network training completed successfully\n');
        
    catch ME
        fprintf('✗ Neural network training failed: %s\n', ME.message);
        fprintf('Error details: %s\n', getReport(ME, 'extended'));
        
        if pipeline_config.run_model_evaluation
            fprintf('\nWarning: Model evaluation may fail without trained model\n');
            response = input('Continue with model evaluation? (y/n): ', 's');
            if ~strcmpi(response, 'y')
                fprintf('Pipeline stopped by user\n');
                return;
            end
        end
    end
end

%% Phase 3: Model Evaluation
if pipeline_config.run_model_evaluation
    fprintf('\n=== Phase 3: Model Evaluation ===\n');
    
    try
        % Find trained model
        model_files = dir('kinematics_to_polynomial_model_*.mat');
        if isempty(model_files)
            fprintf('✗ No trained model files found. Please run neural network training first.\n');
            return;
        end
        
        % Load most recent model
        [~, idx] = max([model_files.datenum]);
        model_path = model_files(idx).name;
        fprintf('Loading model: %s\n', model_path);
        
        model_data = load(model_path);
        model = model_data.model;
        
        % Evaluate model performance
        fprintf('Model Performance Summary:\n');
        fprintf('  Mean RMSE: %.4f\n', model.performance.mean_rmse);
        fprintf('  Mean MAE: %.4f\n', model.performance.mean_mae);
        fprintf('  Mean R²: %.4f\n', model.performance.mean_r_squared);
        fprintf('  Training time: %.2f seconds\n', model.training_time);
        
        % Test prediction function
        if pipeline_config.generate_prediction_functions
            fprintf('\nTesting prediction function...\n');
            
            % Find prediction function
            pred_files = dir('predictPolynomialFromKinematics_*.m');
            if ~isempty(pred_files)
                [~, idx] = max([pred_files.datenum]);
                pred_path = pred_files(idx).name;
                
                % Test with sample kinematics
                sample_kinematics = [45.0, 0.1, 0.0, 0.0, 50.0, 1.0]; % Example features
                
                try
                    % Run prediction function
                    polynomial_coeffs = feval(strrep(pred_path, '.m', ''), sample_kinematics);
                    
                    fprintf('✓ Prediction function test successful\n');
                    fprintf('  Sample input: [%s]\n', num2str(sample_kinematics));
                    fprintf('  Output coefficients: %d total\n', length(fieldnames(polynomial_coeffs)));
                    
                catch ME
                    fprintf('✗ Prediction function test failed: %s\n', ME.message);
                end
            end
        end
        
        fprintf('✓ Model evaluation completed successfully\n');
        
    catch ME
        fprintf('✗ Model evaluation failed: %s\n', ME.message);
        fprintf('Error details: %s\n', getReport(ME, 'extended'));
    end
end

%% Phase 4: Generate Comprehensive Report
if pipeline_config.generate_report
    fprintf('\n=== Phase 4: Generating Comprehensive Report ===\n');
    
    try
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        report_filename = sprintf('pipeline_report_%s.txt', timestamp);
        
        fid = fopen(report_filename, 'w');
        
        fprintf(fid, '=== Golf Swing Neural Network Pipeline Report ===\n\n');
        fprintf(fid, 'Pipeline Execution Date: %s\n', datestr(now));
        fprintf(fid, 'Pipeline Version: 1.0\n\n');
        
        % Dataset information
        dataset_files = dir('golf_swing_dataset_*.mat');
        if ~isempty(dataset_files)
            [~, idx] = max([dataset_files.datenum]);
            dataset_path = dataset_files(idx).name;
            dataset_info = dir(dataset_path);
            
            fprintf(fid, 'Dataset Information:\n');
            fprintf(fid, '  File: %s\n', dataset_path);
            fprintf(fid, '  Size: %.2f MB\n', dataset_info.bytes / (1024^2));
            fprintf(fid, '  Created: %s\n', datestr(dataset_info.datenum));
            fprintf(fid, '\n');
        end
        
        % Model information
        model_files = dir('kinematics_to_polynomial_model_*.mat');
        if ~isempty(model_files)
            [~, idx] = max([model_files.datenum]);
            model_path = model_files(idx).name;
            model_info = dir(model_path);
            
            fprintf(fid, 'Model Information:\n');
            fprintf(fid, '  File: %s\n', model_path);
            fprintf(fid, '  Size: %.2f MB\n', model_info.bytes / (1024^2));
            fprintf(fid, '  Created: %s\n', datestr(model_info.datenum));
            
            % Load model for detailed info
            try
                model_data = load(model_path);
                model = model_data.model;
                
                fprintf(fid, '  Architecture: [%s]\n', num2str(model.config.hidden_layers));
                fprintf(fid, '  Learning rate: %.6f\n', model.config.learning_rate);
                fprintf(fid, '  Training time: %.2f seconds\n', model.training_time);
                fprintf(fid, '  Mean RMSE: %.4f\n', model.performance.mean_rmse);
                fprintf(fid, '  Mean R²: %.4f\n', model.performance.mean_r_squared);
            catch
                fprintf(fid, '  (Model details unavailable)\n');
            end
            fprintf(fid, '\n');
        end
        
        % Generated files
        fprintf(fid, 'Generated Files:\n');
        all_files = dir('*_*.mat');
        for i = 1:length(all_files)
            if ~isempty(strfind(all_files(i).name, 'golf_swing_dataset')) || ...
               ~isempty(strfind(all_files(i).name, 'kinematics_to_polynomial_model'))
                fprintf(fid, '  %s (%.2f MB)\n', all_files(i).name, all_files(i).bytes / (1024^2));
            end
        end
        
        % Usage instructions
        fprintf(fid, '\nUsage Instructions:\n');
        fprintf(fid, '1. Load the trained model:\n');
        fprintf(fid, '   model_data = load(''%s'');\n', model_path);
        fprintf(fid, '   model = model_data.model;\n\n');
        
        fprintf(fid, '2. Make predictions:\n');
        fprintf(fid, '   desired_kinematics = [45.0, 0.1, 0.0, 0.0, 50.0, 1.0];\n');
        fprintf(fid, '   polynomial_coeffs = predictPolynomialFromKinematics(desired_kinematics);\n\n');
        
        fprintf(fid, '3. Apply to simulation:\n');
        fprintf(fid, '   success = updateModelParameters(polynomial_coeffs, starting_positions);\n');
        fprintf(fid, '   [simOut, success, error_msg] = runSimulation(''GolfSwing3D_Kinetic'');\n\n');
        
        fclose(fid);
        
        fprintf('✓ Comprehensive report generated: %s\n', report_filename);
        
    catch ME
        fprintf('✗ Report generation failed: %s\n', ME.message);
    end
end

%% Pipeline Summary
fprintf('\n=== Pipeline Summary ===\n');

% Count generated files
test_files = dir('test_dataset_verification_*.mat');
dataset_files = dir('golf_swing_dataset_*.mat');
model_files = dir('kinematics_to_polynomial_model_*.mat');
pred_files = dir('predictPolynomialFromKinematics_*.m');
report_files = dir('pipeline_report_*.txt');

fprintf('Generated Files:\n');
fprintf('  Test datasets: %d\n', length(test_files));
fprintf('  Datasets: %d\n', length(dataset_files));
fprintf('  Models: %d\n', length(model_files));
fprintf('  Prediction functions: %d\n', length(pred_files));
fprintf('  Reports: %d\n', length(report_files));

% Check for successful completion
if pipeline_config.run_system_verification && ~isempty(test_files)
    fprintf('✓ System verification: SUCCESS\n');
elseif pipeline_config.run_system_verification
    fprintf('✗ System verification: FAILED\n');
end

if pipeline_config.run_dataset_generation && ~isempty(dataset_files)
    fprintf('✓ Dataset generation: SUCCESS\n');
elseif pipeline_config.run_dataset_generation
    fprintf('✗ Dataset generation: FAILED\n');
end

if pipeline_config.run_neural_network_training && ~isempty(model_files)
    fprintf('✓ Neural network training: SUCCESS\n');
elseif pipeline_config.run_neural_network_training
    fprintf('✗ Neural network training: FAILED\n');
end

if pipeline_config.run_model_evaluation && ~isempty(model_files)
    fprintf('✓ Model evaluation: SUCCESS\n');
elseif pipeline_config.run_model_evaluation
    fprintf('✗ Model evaluation: FAILED\n');
end

if pipeline_config.generate_prediction_functions && ~isempty(pred_files)
    fprintf('✓ Prediction functions: SUCCESS\n');
elseif pipeline_config.generate_prediction_functions
    fprintf('✗ Prediction functions: FAILED\n');
end

fprintf('\n=== Pipeline Complete ===\n');

if ~isempty(model_files) && ~isempty(dataset_files)
    fprintf('🎉 Pipeline completed successfully!\n');
    fprintf('You can now use the trained model to predict polynomial coefficients from desired kinematics.\n');
else
    fprintf('⚠️  Pipeline completed with some failures.\n');
    fprintf('Check the error messages above and review the generated files.\n');
end

fprintf('\nNext steps:\n');
fprintf('1. Test the prediction function with your desired kinematics\n');
fprintf('2. Apply the predicted coefficients to your Simulink model\n');
fprintf('3. Run simulations to verify the results\n');
fprintf('4. Fine-tune the model if needed\n'); 
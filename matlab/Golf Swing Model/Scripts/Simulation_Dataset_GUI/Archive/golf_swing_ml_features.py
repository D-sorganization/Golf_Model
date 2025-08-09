# Golf Swing Machine Learning Features
# Comprehensive feature list for golf swing analysis and machine learning
# Updated to include 1x1 matrix signals that were previously skipped

# Core Performance Metrics (Target Variables)
target_variables = [
    "ClubLogs_CHSpeed",  # Club head speed
    "ClubLogs_CHS__mph_",  # Club head speed in mph
    "ClubLogs_MaximumCHS",  # Maximum club head speed
    "ClubLogs_AoA",  # Angle of attack
    "ClubLogs_Path",  # Club path
    "ClubLogs_Face",  # Club face angle
    "MidpointCalcsLogs_Hand_Speed__mph_",  # Hand speed in mph
]

# Joint Kinematics (Primary Features)
joint_kinematics = [
    # Hip Joint
    "HipLogs_HipPositionX",
    "HipLogs_HipPositionY",
    "HipLogs_HipPositionZ",
    "HipLogs_HipVelocityX",
    "HipLogs_HipVelocityY",
    "HipLogs_HipVelocityZ",
    "HipLogs_HipAngularPositionX",
    "HipLogs_HipAngularPositionY",
    "HipLogs_HipAngularPositionZ",
    "HipLogs_HipAngularVelocityX",
    "HipLogs_HipAngularVelocityY",
    "HipLogs_HipAngularVelocityZ",
    # Shoulder Joints
    "LScapLogs_AngularPositionX",
    "LScapLogs_AngularPositionY",
    "RScapLogs_AngularPositionX",
    "RScapLogs_AngularPositionY",
    "LScapLogs_AngularVelocityX",
    "LScapLogs_AngularVelocityY",
    "RScapLogs_AngularVelocityX",
    "RScapLogs_AngularVelocityY",
    # Arms
    "LSLogs_AngularPositionX",
    "LSLogs_AngularPositionY",
    "LSLogs_AngularPosition_Z",
    "RSLogs_AngularPositionX",
    "RSLogs_AngularPositionY",
    "RSLogs_AngularPosition_Z",
    "LSLogs_AngularVelocityX",
    "LSLogs_AngularVelocityY",
    "LSLogs_AngularVelocityZ",
    "RSLogs_AngularVelocityX",
    "RSLogs_AngularVelocityY",
    "RSLogs_AngularVelocityZ",
    # Wrists
    "LWLogs_LHGlobalAngularVelocity_1",
    "LWLogs_LHGlobalAngularVelocity_2",
    "LWLogs_LHGlobalAngularVelocity_3",
    "RWLogs_RHGlobalAngularVelocity_1",
    "RWLogs_RHGlobalAngularVelocity_2",
    "RWLogs_RHGlobalAngularVelocity_3",
    # Elbows
    "LELogs_LArmonLForearmFGlobal_1",
    "LELogs_LArmonLForearmFGlobal_2",
    "LELogs_LArmonLForearmFGlobal_3",
    "RELogs_RArmonLForearmFGlobal_1",
    "RELogs_RArmonLForearmFGlobal_2",
    "RELogs_RArmonLForearmFGlobal_3",
    # Spine and Torso
    "SpineLogs_AngularPositionX",
    "SpineLogs_AngularPositionY",
    "SpineLogs_AngularVelocityX",
    "SpineLogs_AngularVelocityY",
    "TorsoLogs_AngularPosition",
    "TorsoLogs_AngularVelocity",
]

# Forces and Torques (Biomechanical Features)
forces_torques = [
    # Hand Forces on Club
    "ClubLogs_RHonClubForceLocal_1",
    "ClubLogs_RHonClubForceLocal_2",
    "ClubLogs_RHonClubForceLocal_3",
    "ClubLogs_LHonClubForceLocal_1",
    "ClubLogs_LHonClubForceLocal_2",
    "ClubLogs_LHonClubForceLocal_3",
    "ClubLogs_RHonClubTorqueLocal_1",
    "ClubLogs_RHonClubTorqueLocal_2",
    "ClubLogs_RHonClubTorqueLocal_3",
    "ClubLogs_LHonClubTorqueLocal_1",
    "ClubLogs_LHonClubTorqueLocal_2",
    "ClubLogs_LHonClubTorqueLocal_3",
    # Joint Forces
    "LScapLogs_ForceLocal_1",
    "LScapLogs_ForceLocal_2",
    "LScapLogs_ForceLocal_3",
    "RScapLogs_ForceLocal_1",
    "RScapLogs_ForceLocal_2",
    "RScapLogs_ForceLocal_3",
    "LSLogs_ForceLocal_1",
    "LSLogs_ForceLocal_2",
    "LSLogs_ForceLocal_3",
    "RSLogs_ForceLocal_1",
    "RSLogs_ForceLocal_2",
    "RSLogs_ForceLocal_3",
    # Joint Torques
    "LScapLogs_TorqueLocal_1",
    "LScapLogs_TorqueLocal_2",
    "LScapLogs_TorqueLocal_3",
    "RScapLogs_TorqueLocal_1",
    "RScapLogs_TorqueLocal_2",
    "RScapLogs_TorqueLocal_3",
    "LSLogs_TorqueLocal_1",
    "LSLogs_TorqueLocal_2",
    "LSLogs_TorqueLocal_3",
    "RSLogs_TorqueLocal_1",
    "RSLogs_TorqueLocal_2",
    "RSLogs_TorqueLocal_3",
]

# Calculated Power and Work (Performance Metrics)
power_work = [
    "CalculatedSignalsLogs_LinearPoweronClub",
    "CalculatedSignalsLogs_LHonClubAngularPower",
    "CalculatedSignalsLogs_RHonClubAngularPower",
    "CalculatedSignalsLogs_LHonClubLinearPower",
    "CalculatedSignalsLogs_RHonClubLinearPower",
    "IntegratedSignalsLogs_LinearWorkonClub",
    "IntegratedSignalsLogs_LHAngularWorkonClub",
    "IntegratedSignalsLogs_RHAngularWorkonClub",
]

# Hand Positions and Velocities
hand_kinematics = [
    "LHCalcsLogs_LeftHandSpeed",
    "LHCalcsLogs_LHGlobalVelocity_1",
    "LHCalcsLogs_LHGlobalVelocity_2",
    "LHCalcsLogs_LHGlobalVelocity_3",
    "LHCalcsLogs_LeftHandPostion_1",
    "LHCalcsLogs_LeftHandPostion_2",
    "LHCalcsLogs_LeftHandPostion_3",
    "RHCalcsLogs_RightHandSpeed",
    "RHCalcsLogs_RHGlobalVelocity_1",
    "RHCalcsLogs_RHGlobalVelocity_2",
    "RHCalcsLogs_RHGlobalVelocity_3",
    "RHCalcsLogs_RightHandPostion_1",
    "RHCalcsLogs_RightHandPostion_2",
    "RHCalcsLogs_RightHandPostion_3",
    "MidpointCalcsLogs_MidHandSpeed",
    "MidpointCalcsLogs_MPGlobalVelocity_1",
    "MidpointCalcsLogs_MPGlobalVelocity_2",
    "MidpointCalcsLogs_MPGlobalVelocity_3",
    "MidpointCalcsLogs_MPGlobalPosition_1",
    "MidpointCalcsLogs_MPGlobalPosition_2",
    "MidpointCalcsLogs_MPGlobalPosition_3",
]

# Club Properties
club_properties = [
    "ClubLogs_ClubMass",
    "ClubLogs_ClubCOM_1",
    "ClubLogs_ClubCOM_2",
    "ClubLogs_ClubCOM_3",
    "ClubLogs_CHGlobalPosition_1",
    "ClubLogs_CHGlobalPosition_2",
    "ClubLogs_CHGlobalPosition_3",
    "ClubLogs_CHGlobalVelocity_1",
    "ClubLogs_CHGlobalVelocity_2",
    "ClubLogs_CHGlobalVelocity_3",
    "ClubLogs_TipPosition_1",
    "ClubLogs_TipPosition_2",
    "ClubLogs_TipPosition_3",
]

# Moments and Couples
moments_couples = [
    "MomentandCoupleLogs_LHMOFonClubLocal_1",
    "MomentandCoupleLogs_LHMOFonClubLocal_2",
    "MomentandCoupleLogs_LHMOFonClubLocal_3",
    "MomentandCoupleLogs_RHMOFonClubGlobal_1",
    "MomentandCoupleLogs_RHMOFonClubGlobal_2",
    "MomentandCoupleLogs_RHMOFonClubGlobal_3",
    "MomentandCoupleLogs_MPMOFonClubLocal_1",
    "MomentandCoupleLogs_MPMOFonClubLocal_2",
    "MomentandCoupleLogs_MPMOFonClubLocal_3",
    "MomentandCoupleLogs_SumofMomentsonClubLocal_1",
    "MomentandCoupleLogs_SumofMomentsonClubLocal_2",
    "MomentandCoupleLogs_SumofMomentsonClubLocal_3",
]

# Input Parameters (Model Configuration)
input_parameters = [
    # Polynomial coefficients (A-G for each joint)
    "input_HipX_A",
    "input_HipX_B",
    "input_HipX_C",
    "input_HipX_D",
    "input_HipX_E",
    "input_HipX_F",
    "input_HipX_G",
    "input_HipY_A",
    "input_HipY_B",
    "input_HipY_C",
    "input_HipY_D",
    "input_HipY_E",
    "input_HipY_F",
    "input_HipY_G",
    "input_HipZ_A",
    "input_HipZ_B",
    "input_HipZ_C",
    "input_HipZ_D",
    "input_HipZ_E",
    "input_HipZ_F",
    "input_HipZ_G",
    "input_LSX_A",
    "input_LSX_B",
    "input_LSX_C",
    "input_LSX_D",
    "input_LSX_E",
    "input_LSX_F",
    "input_LSX_G",
    "input_LSY_A",
    "input_LSY_B",
    "input_LSY_C",
    "input_LSY_D",
    "input_LSY_E",
    "input_LSY_F",
    "input_LSY_G",
    "input_LSZ_A",
    "input_LSZ_B",
    "input_LSZ_C",
    "input_LSZ_D",
    "input_LSZ_E",
    "input_LSZ_F",
    "input_LSZ_G",
    "input_RSX_A",
    "input_RSX_B",
    "input_RSX_C",
    "input_RSX_D",
    "input_RSX_E",
    "input_RSX_F",
    "input_RSX_G",
    "input_RSY_A",
    "input_RSY_B",
    "input_RSY_C",
    "input_RSY_D",
    "input_RSY_E",
    "input_RSY_F",
    "input_RSY_G",
    "input_RSZ_A",
    "input_RSZ_B",
    "input_RSZ_C",
    "input_RSZ_D",
    "input_RSZ_E",
    "input_RSZ_F",
    "input_RSZ_G",
    "input_LWX_A",
    "input_LWX_B",
    "input_LWX_C",
    "input_LWX_D",
    "input_LWX_E",
    "input_LWX_F",
    "input_LWX_G",
    "input_LWY_A",
    "input_LWY_B",
    "input_LWY_C",
    "input_LWY_D",
    "input_LWY_E",
    "input_LWY_F",
    "input_LWY_G",
    "input_RWX_A",
    "input_RWX_B",
    "input_RWX_C",
    "input_RWX_D",
    "input_RWX_E",
    "input_RWX_F",
    "input_RWX_G",
    "input_RWY_A",
    "input_RWY_B",
    "input_RWY_C",
    "input_RWY_D",
    "input_RWY_E",
    "input_RWY_F",
    "input_RWY_G",
    "input_SpineX_A",
    "input_SpineX_B",
    "input_SpineX_C",
    "input_SpineX_D",
    "input_SpineX_E",
    "input_SpineX_F",
    "input_SpineX_G",
    "input_SpineY_A",
    "input_SpineY_B",
    "input_SpineY_C",
    "input_SpineY_D",
    "input_SpineY_E",
    "input_SpineY_F",
    "input_SpineY_G",
    "input_Torso_A",
    "input_Torso_B",
    "input_Torso_C",
    "input_Torso_D",
    "input_Torso_E",
    "input_Torso_F",
    "input_Torso_G",
    "input_TranslationX_A",
    "input_TranslationX_B",
    "input_TranslationX_C",
    "input_TranslationX_D",
    "input_TranslationX_E",
    "input_TranslationX_F",
    "input_TranslationX_G",
    "input_TranslationY_A",
    "input_TranslationY_B",
    "input_TranslationY_C",
    "input_TranslationY_D",
    "input_TranslationY_E",
    "input_TranslationY_F",
    "input_TranslationY_G",
    "input_TranslationZ_A",
    "input_TranslationZ_B",
    "input_TranslationZ_C",
    "input_TranslationZ_D",
    "input_TranslationZ_E",
    "input_TranslationZ_F",
    "input_TranslationZ_G",
    "input_LE_A",
    "input_LE_B",
    "input_LE_C",
    "input_LE_D",
    "input_LE_E",
    "input_LE_F",
    "input_LE_G",
    "input_RE_A",
    "input_RE_B",
    "input_RE_C",
    "input_RE_D",
    "input_RE_E",
    "input_RE_F",
    "input_RE_G",
    "input_LF_A",
    "input_LF_B",
    "input_LF_C",
    "input_LF_D",
    "input_LF_E",
    "input_LF_F",
    "input_LF_G",
    "input_RF_A",
    "input_RF_B",
    "input_RF_C",
    "input_RF_D",
    "input_RF_E",
    "input_RF_F",
    "input_RF_G",
    "input_LScapX_A",
    "input_LScapX_B",
    "input_LScapX_C",
    "input_LScapX_D",
    "input_LScapX_E",
    "input_LScapX_F",
    "input_LScapX_G",
    "input_LScapY_A",
    "input_LScapY_B",
    "input_LScapY_C",
    "input_LScapY_D",
    "input_LScapY_E",
    "input_LScapY_F",
    "input_LScapY_G",
    "input_RScapX_A",
    "input_RScapX_B",
    "input_RScapX_C",
    "input_RScapX_D",
    "input_RScapX_E",
    "input_RScapX_F",
    "input_RScapX_G",
    "input_RScapY_A",
    "input_RScapY_B",
    "input_RScapY_C",
    "input_RScapY_D",
    "input_RScapY_E",
    "input_RScapY_F",
    "input_RScapY_G",
]

# Model Configuration Parameters
model_config = [
    "model_ActuationMode",
    "model_ModelingMode",
    "model_StopTime",
    "model_GlobalGain",
    "model_GlobalPCGain",
    "model_GlobalVCGain",
    "model_DampeningGlobalGain",
    "model_ClubheadMass",
    "model_ClubheadRadius",
    "model_ShaftLength",
    "model_ShaftStiffness",
    "model_ShaftDampening",
    "model_GripStrength",
]

# Scalar Signals (previously skipped 1x1 matrices) - NOW INCLUDED
scalar_signals = [
    "MidpointCalcsLogs_signal7",  # This was the specific signal mentioned
    "RHCalcsLogs_signal2",  # Right hand calculations signal 2
    # Additional scalar signals that will be captured with the fix:
    "LHCalcsLogs_signal1",  # Left hand calculations signal 1 (if exists)
    "LHCalcsLogs_signal2",  # Left hand calculations signal 2 (if exists)
    "LHCalcsLogs_signal3",  # Left hand calculations signal 3 (if exists)
    "RHCalcsLogs_signal1",  # Right hand calculations signal 1 (if exists)
    "RHCalcsLogs_signal3",  # Right hand calculations signal 3 (if exists)
    "MidpointCalcsLogs_signal1",  # Midpoint calculations signal 1 (if exists)
    "MidpointCalcsLogs_signal2",  # Midpoint calculations signal 2 (if exists)
    "MidpointCalcsLogs_signal3",  # Midpoint calculations signal 3 (if exists)
    "MidpointCalcsLogs_signal4",  # Midpoint calculations signal 4 (if exists)
    "MidpointCalcsLogs_signal5",  # Midpoint calculations signal 5 (if exists)
    "MidpointCalcsLogs_signal6",  # Midpoint calculations signal 6 (if exists)
    "MidpointCalcsLogs_signal8",  # Midpoint calculations signal 8 (if exists)
    "MidpointCalcsLogs_signal9",  # Midpoint calculations signal 9 (if exists)
    # Add other potential scalar signals from different categories
    "ClubLogs_signal1",  # Club logs signal 1 (if exists)
    "ClubLogs_signal2",  # Club logs signal 2 (if exists)
    "HipLogs_signal1",  # Hip logs signal 1 (if exists)
    "HipLogs_signal2",  # Hip logs signal 2 (if exists)
    "TorsoLogs_signal1",  # Torso logs signal 1 (if exists)
    "TorsoLogs_signal2",  # Torso logs signal 2 (if exists)
    "SpineLogs_signal1",  # Spine logs signal 1 (if exists)
    "SpineLogs_signal2",  # Spine logs signal 2 (if exists)
    "LScapLogs_signal1",  # Left scapula logs signal 1 (if exists)
    "RScapLogs_signal1",  # Right scapula logs signal 1 (if exists)
    "LSLogs_signal1",  # Left shoulder logs signal 1 (if exists)
    "RSLogs_signal1",  # Right shoulder logs signal 1 (if exists)
    "LWLogs_signal1",  # Left wrist logs signal 1 (if exists)
    "RWLogs_signal1",  # Right wrist logs signal 1 (if exists)
    "LELogs_signal1",  # Left elbow logs signal 1 (if exists)
    "RELogs_signal1",  # Right elbow logs signal 1 (if exists)
    "LFLogs_signal1",  # Left forearm logs signal 1 (if exists)
    "RFLogs_signal1",  # Right forearm logs signal 1 (if exists)
]

# Time-based features (for temporal analysis)
time_features = [
    "time",  # Time column for temporal analysis
]

# Combined feature lists for different ML approaches
all_features = (
    joint_kinematics
    + forces_torques
    + power_work
    + hand_kinematics
    + club_properties
    + moments_couples
    + input_parameters
    + model_config
    + time_features
    + scalar_signals  # Add the new scalar signals
)

# High-priority features for initial ML models
priority_features = [
    # Target variables
    "ClubLogs_CHSpeed",
    "ClubLogs_CHS__mph_",
    "ClubLogs_MaximumCHS",
    # Key joint positions
    "HipLogs_HipPositionX",
    "HipLogs_HipPositionY",
    "HipLogs_HipPositionZ",
    "LScapLogs_AngularPositionX",
    "LScapLogs_AngularPositionY",
    "RScapLogs_AngularPositionX",
    "RScapLogs_AngularPositionY",
    "LSLogs_AngularPositionX",
    "LSLogs_AngularPositionY",
    "RSLogs_AngularPositionX",
    "RSLogs_AngularPositionY",
    # Key velocities
    "HipLogs_HipVelocityX",
    "HipLogs_HipVelocityY",
    "HipLogs_HipVelocityZ",
    "MidpointCalcsLogs_MidHandSpeed",
    # Key forces
    "ClubLogs_RHonClubForceLocal_1",
    "ClubLogs_RHonClubForceLocal_2",
    "ClubLogs_RHonClubForceLocal_3",
    "ClubLogs_LHonClubForceLocal_1",
    "ClubLogs_LHonClubForceLocal_2",
    "ClubLogs_LHonClubForceLocal_3",
    # Key input parameters (first few coefficients for each joint)
    "input_HipX_A",
    "input_HipX_B",
    "input_HipX_C",
    "input_LSX_A",
    "input_LSX_B",
    "input_LSX_C",
    "input_RSX_A",
    "input_RSX_B",
    "input_RSX_C",
    "input_LWX_A",
    "input_LWX_B",
    "input_LWX_C",
    "input_RWX_A",
    "input_RWX_B",
    "input_RWX_C",
    # Specific scalar signals that were mentioned as missing
    "MidpointCalcsLogs_signal7",
    "RHCalcsLogs_signal2",
]

# Feature categories for different ML tasks
feature_categories = {
    "regression_targets": target_variables,
    "classification_features": joint_kinematics + forces_torques + hand_kinematics,
    "temporal_features": time_features + joint_kinematics + forces_torques,
    "biomechanical_features": forces_torques + power_work + moments_couples,
    "input_features": input_parameters + model_config,
    "performance_metrics": target_variables + power_work + hand_kinematics,
    "scalar_signals": scalar_signals,  # New category for 1x1 matrix signals
    "hand_calculations": [
        "LHCalcsLogs_LeftHandSpeed",
        "LHCalcsLogs_LHGlobalVelocity_1",
        "LHCalcsLogs_LHGlobalVelocity_2",
        "LHCalcsLogs_LHGlobalVelocity_3",
        "LHCalcsLogs_LeftHandPostion_1",
        "LHCalcsLogs_LeftHandPostion_2",
        "LHCalcsLogs_LeftHandPostion_3",
        "RHCalcsLogs_RightHandSpeed",
        "RHCalcsLogs_RHGlobalVelocity_1",
        "RHCalcsLogs_RHGlobalVelocity_2",
        "RHCalcsLogs_RHGlobalVelocity_3",
        "RHCalcsLogs_RightHandPostion_1",
        "RHCalcsLogs_RightHandPostion_2",
        "RHCalcsLogs_RightHandPostion_3",
        "MidpointCalcsLogs_MidHandSpeed",
        "MidpointCalcsLogs_MPGlobalVelocity_1",
        "MidpointCalcsLogs_MPGlobalVelocity_2",
        "MidpointCalcsLogs_MPGlobalVelocity_3",
        "MidpointCalcsLogs_MPGlobalPosition_1",
        "MidpointCalcsLogs_MPGlobalPosition_2",
        "MidpointCalcsLogs_MPGlobalPosition_3",
        # Include the scalar signals in hand calculations
        "MidpointCalcsLogs_signal7",
        "RHCalcsLogs_signal2",
        "LHCalcsLogs_signal1",
        "LHCalcsLogs_signal2",
        "LHCalcsLogs_signal3",
        "RHCalcsLogs_signal1",
        "RHCalcsLogs_signal3",
        "MidpointCalcsLogs_signal1",
        "MidpointCalcsLogs_signal2",
        "MidpointCalcsLogs_signal3",
        "MidpointCalcsLogs_signal4",
        "MidpointCalcsLogs_signal5",
        "MidpointCalcsLogs_signal6",
        "MidpointCalcsLogs_signal8",
        "MidpointCalcsLogs_signal9",
    ],
}


# Function to dynamically discover scalar signals from CSV data
def discover_scalar_signals(csv_file_path):
    """
    Dynamically discover scalar signals from CSV data after the fix is applied.
    This function can be used to find all 1x1 matrix signals that are now being captured.

    Args:
        csv_file_path (str): Path to the CSV file containing the extracted data

    Returns:
        list: List of column names that represent scalar signals
    """
    import pandas as pd

    try:
        # Read the CSV file
        df = pd.read_csv(csv_file_path)

        # Find columns that likely represent scalar signals
        # Look for patterns like '*_signal*' or columns with constant values
        scalar_columns = []

        for col in df.columns:
            # Check if column name contains 'signal' (case insensitive)
            if "signal" in col.lower():
                scalar_columns.append(col)

            # Check if column has constant values (potential scalar signal)
            elif len(df[col].unique()) == 1:
                scalar_columns.append(col)

        return scalar_columns

    except Exception as e:
        print(f"Error discovering scalar signals: {e}")
        return []


# Function to validate scalar signal extraction
def validate_scalar_extraction(csv_file_path, expected_scalars):
    """
    Validate that scalar signals are being properly extracted.

    Args:
        csv_file_path (str): Path to the CSV file
        expected_scalars (list): List of expected scalar signal names

    Returns:
        dict: Validation results
    """
    import pandas as pd

    try:
        df = pd.read_csv(csv_file_path)

        results = {
            "found_signals": [],
            "missing_signals": [],
            "total_columns": len(df.columns),
            "total_rows": len(df),
        }

        for signal in expected_scalars:
            if signal in df.columns:
                results["found_signals"].append(signal)
            else:
                results["missing_signals"].append(signal)

        return results

    except Exception as e:
        return {"error": str(e)}


# Function to load and prepare data for machine learning
def load_golf_swing_data(csv_file_path, feature_list=None, target_variables=None):
    """
    Load golf swing data and prepare it for machine learning.

    Args:
        csv_file_path (str): Path to the CSV file
        feature_list (list): List of features to use (default: priority_features)
        target_variables (list): List of target variables (default: target_variables)

    Returns:
        tuple: (X, y, feature_names, target_names)
    """
    import numpy as np
    import pandas as pd

    try:
        # Load data
        df = pd.read_csv(csv_file_path)

        # Use default feature lists if not provided
        if feature_list is None:
            feature_list = priority_features
        if target_variables is None:
            target_variables = target_variables

        # Filter features that exist in the dataset
        available_features = [f for f in feature_list if f in df.columns]
        available_targets = [t for t in target_variables if t in df.columns]

        print(
            f"Using {len(available_features)} features out of {len(feature_list)} requested"
        )
        print(
            f"Using {len(available_targets)} targets out of {len(target_variables)} requested"
        )

        # Prepare X and y
        X = df[available_features].values
        y = df[available_targets].values if available_targets else None

        # Handle missing values
        X = np.nan_to_num(X, nan=0.0)
        if y is not None:
            y = np.nan_to_num(y, nan=0.0)

        return X, y, available_features, available_targets

    except Exception as e:
        print(f"Error loading golf swing data: {e}")
        return None, None, None, None


# Example usage
if __name__ == "__main__":
    print("Golf Swing Machine Learning Features")
    print("=" * 50)
    print(f"Total features available: {len(all_features)}")
    print(f"Priority features: {len(priority_features)}")
    print(f"Target variables: {len(target_variables)}")
    print(f"Scalar signals: {len(scalar_signals)}")

    print("\nFeature Categories:")
    for category, features in feature_categories.items():
        print(f"  {category}: {len(features)} features")

    print("\nExample usage:")
    print("# Load data for machine learning")
    print("X, y, features, targets = load_golf_swing_data('your_data.csv')")
    print("# Discover scalar signals")
    print("scalars = discover_scalar_signals('your_data.csv')")
    print("# Validate extraction")
    print("validation = validate_scalar_extraction('your_data.csv', scalar_signals)")

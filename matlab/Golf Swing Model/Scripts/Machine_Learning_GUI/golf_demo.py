#!/usr/bin/env python3
"""
Golf Swing Motion Matching Demo & Analysis
==========================================

This script demonstrates the complete workflow for matching polynomial coefficients
to motion capture data and provides additional analysis tools.

Author: Golf Swing Simulation Project
Date: 2025
"""

import os
import sys
from datetime import datetime

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.gridspec import GridSpec

# Import the main motion matching system
# (Assuming the main script is saved as golf_swing_motion_matching.py)
try:
    from golf_swing_motion_matching import (
        GolfSwingKinematics,
        GolfSwingMotionMatching,
        PolynomialCoefficientOptimizer,
        WiffleDataLoader,
    )
except ImportError:
    print("Please ensure golf_swing_motion_matching.py is in the same directory")
    sys.exit(1)


class MotionAnalyzer:
    """
    Additional analysis tools for golf swing motion matching.
    """

    def __init__(self):
        self.kinematics = GolfSwingKinematics()

    def analyze_joint_contributions(self, coefficients, target_trajectory):
        """
        Analyze how each joint contributes to the hand trajectory.

        Args:
            coefficients (dict): Polynomial coefficients for all joints
            target_trajectory (np.array): Target hand positions

        Returns:
            dict: Analysis results
        """
        print("\nAnalyzing joint contributions to hand trajectory...")

        n_time = len(target_trajectory)
        time_vec = np.linspace(0, 1, n_time)

        # Baseline: all joints at zero
        baseline_angles = {joint: np.zeros(n_time) for joint in coefficients.keys()}
        baseline_positions = []
        for t in range(n_time):
            pos, _ = self.kinematics.compute_positions(baseline_angles, time_idx=t)
            baseline_positions.append(pos["hand_midpoint"])
        baseline_positions = np.array(baseline_positions)

        # Analyze each joint's contribution
        contributions = {}

        for joint in coefficients.keys():
            # Activate only this joint
            test_angles = baseline_angles.copy()

            # Compute angles for this joint from polynomial
            angles = np.zeros(n_time)
            for i, coeff_name in enumerate(["A", "B", "C", "D", "E", "F", "G"]):
                if coeff_name in coefficients[joint]:
                    angles += coefficients[joint][coeff_name] * (time_vec**i)
            test_angles[joint] = angles

            # Compute resulting positions
            test_positions = []
            for t in range(n_time):
                pos, _ = self.kinematics.compute_positions(test_angles, time_idx=t)
                test_positions.append(pos["hand_midpoint"])
            test_positions = np.array(test_positions)

            # Calculate contribution
            contribution = np.linalg.norm(test_positions - baseline_positions, axis=1)
            contributions[joint] = {
                "trajectory": test_positions,
                "magnitude": contribution,
                "mean_contribution": np.mean(contribution),
                "max_contribution": np.max(contribution),
            }

        # Sort joints by mean contribution
        sorted_joints = sorted(
            contributions.keys(),
            key=lambda j: contributions[j]["mean_contribution"],
            reverse=True,
        )

        print("\nJoint contributions (sorted by mean effect):")
        for joint in sorted_joints[:10]:  # Top 10
            mean_contrib = contributions[joint]["mean_contribution"]
            max_contrib = contributions[joint]["max_contribution"]
            print(f"  {joint:15s}: mean={mean_contrib:.3f}m, max={max_contrib:.3f}m")

        return contributions

    def compute_joint_velocities(self, coefficients, time_duration=1.0, n_points=100):
        """
        Compute joint angular velocities from polynomial coefficients.

        Args:
            coefficients (dict): Polynomial coefficients
            time_duration (float): Duration of motion
            n_points (int): Number of time points

        Returns:
            dict: Joint velocities
        """
        time_vec = np.linspace(0, time_duration, n_points)
        dt = time_vec[1] - time_vec[0]

        velocities = {}

        for joint, coeffs in coefficients.items():
            # Compute angles
            angles = np.zeros(n_points)
            for i, coeff_name in enumerate(["A", "B", "C", "D", "E", "F", "G"]):
                if coeff_name in coeffs:
                    angles += coeffs[coeff_name] * (time_vec**i)

            # Compute velocity (derivative)
            velocity = np.gradient(angles, dt)

            # Compute acceleration (second derivative)
            acceleration = np.gradient(velocity, dt)

            velocities[joint] = {
                "angles": angles,
                "velocity": velocity,
                "acceleration": acceleration,
                "max_velocity": np.max(np.abs(velocity)),
                "max_acceleration": np.max(np.abs(acceleration)),
            }

        return velocities

    def plot_joint_analysis(
        self, coefficients, mocap_data, output_dir="analysis_results"
    ):
        """
        Create comprehensive analysis plots.

        Args:
            coefficients (dict): Optimized polynomial coefficients
            mocap_data (dict): Motion capture data
            output_dir (str): Directory to save plots
        """
        os.makedirs(output_dir, exist_ok=True)

        # Get joint velocities
        velocities = self.compute_joint_velocities(
            coefficients, time_duration=mocap_data["time"][-1]
        )

        # Create multi-panel figure
        fig = plt.figure(figsize=(20, 16))
        gs = GridSpec(4, 3, figure=fig, hspace=0.3, wspace=0.3)

        # Panel 1: Joint angles over time
        ax1 = fig.add_subplot(gs[0, :])
        self._plot_joint_angles(ax1, velocities, coefficients)

        # Panel 2: Joint velocities
        ax2 = fig.add_subplot(gs[1, :])
        self._plot_joint_velocities(ax2, velocities)

        # Panel 3: Joint accelerations
        ax3 = fig.add_subplot(gs[2, :])
        self._plot_joint_accelerations(ax3, velocities)

        # Panel 4: Coefficient magnitude analysis
        ax4 = fig.add_subplot(gs[3, 0])
        self._plot_coefficient_magnitudes(ax4, coefficients)

        # Panel 5: Joint contribution pie chart
        ax5 = fig.add_subplot(gs[3, 1])
        contributions = self.analyze_joint_contributions(
            coefficients, mocap_data["midhand_positions"]
        )
        self._plot_contribution_pie(ax5, contributions)

        # Panel 6: Polynomial order analysis
        ax6 = fig.add_subplot(gs[3, 2])
        self._plot_polynomial_orders(ax6, coefficients)

        plt.suptitle("Golf Swing Motion Analysis", fontsize=16, fontweight="bold")
        plt.savefig(
            os.path.join(output_dir, "joint_analysis.png"), dpi=300, bbox_inches="tight"
        )
        plt.close()

        print(f"\nAnalysis plots saved to {output_dir}")

    def _plot_joint_angles(self, ax, velocities, coefficients):
        """Plot joint angles over time."""
        time_vec = np.linspace(0, 1, 100)

        # Select key joints to plot
        key_joints = ["HipX", "HipY", "HipZ", "SpineX", "SpineY", "Torso"]

        for joint in key_joints:
            if joint in velocities:
                angles = velocities[joint]["angles"]
                ax.plot(time_vec, np.rad2deg(angles), label=joint, linewidth=2)

        ax.set_xlabel("Normalized Time")
        ax.set_ylabel("Angle (degrees)")
        ax.set_title("Joint Angles During Swing", fontweight="bold")
        ax.legend(loc="best")
        ax.grid(True, alpha=0.3)

    def _plot_joint_velocities(self, ax, velocities):
        """Plot joint angular velocities."""
        time_vec = np.linspace(0, 1, 100)

        # Select joints with highest velocities
        sorted_joints = sorted(
            velocities.keys(), key=lambda j: velocities[j]["max_velocity"], reverse=True
        )[:6]

        for joint in sorted_joints:
            vel = velocities[joint]["velocity"]
            ax.plot(
                time_vec,
                np.rad2deg(vel),
                label=f"{joint} (max: {velocities[joint]['max_velocity']:.1f}°/s)",
                linewidth=2,
            )

        ax.set_xlabel("Normalized Time")
        ax.set_ylabel("Angular Velocity (deg/s)")
        ax.set_title("Joint Angular Velocities", fontweight="bold")
        ax.legend(loc="best")
        ax.grid(True, alpha=0.3)

    def _plot_joint_accelerations(self, ax, velocities):
        """Plot joint angular accelerations."""
        time_vec = np.linspace(0, 1, 100)

        # Select joints with highest accelerations
        sorted_joints = sorted(
            velocities.keys(),
            key=lambda j: velocities[j]["max_acceleration"],
            reverse=True,
        )[:6]

        for joint in sorted_joints:
            accel = velocities[joint]["acceleration"]
            ax.plot(time_vec, np.rad2deg(accel), label=f"{joint}", linewidth=2)

        ax.set_xlabel("Normalized Time")
        ax.set_ylabel("Angular Acceleration (deg/s²)")
        ax.set_title("Joint Angular Accelerations", fontweight="bold")
        ax.legend(loc="best")
        ax.grid(True, alpha=0.3)

    def _plot_coefficient_magnitudes(self, ax, coefficients):
        """Plot coefficient magnitudes for each joint."""
        joint_names = []
        coeff_magnitudes = []

        for joint, coeffs in coefficients.items():
            if any(coeffs.values()):  # Skip joints with all zero coefficients
                joint_names.append(joint)
                # Calculate RMS of coefficients
                values = [coeffs.get(c, 0) for c in "ABCDEFG"]
                magnitude = np.sqrt(np.mean(np.square(values)))
                coeff_magnitudes.append(magnitude)

        # Sort by magnitude
        sorted_indices = np.argsort(coeff_magnitudes)[::-1][:10]  # Top 10

        ax.barh(
            [joint_names[i] for i in sorted_indices],
            [coeff_magnitudes[i] for i in sorted_indices],
            color="skyblue",
            edgecolor="navy",
        )
        ax.set_xlabel("RMS Coefficient Magnitude")
        ax.set_title("Joint Coefficient Magnitudes", fontweight="bold")
        ax.grid(True, alpha=0.3, axis="x")

    def _plot_contribution_pie(self, ax, contributions):
        """Plot pie chart of joint contributions."""
        # Get top contributors
        sorted_joints = sorted(
            contributions.keys(),
            key=lambda j: contributions[j]["mean_contribution"],
            reverse=True,
        )[:8]

        labels = sorted_joints
        sizes = [contributions[j]["mean_contribution"] for j in sorted_joints]

        # Add "Others" category
        other_contrib = sum(
            contributions[j]["mean_contribution"]
            for j in contributions
            if j not in sorted_joints
        )
        if other_contrib > 0:
            labels.append("Others")
            sizes.append(other_contrib)

        ax.pie(sizes, labels=labels, autopct="%1.1f%%", startangle=90)
        ax.set_title("Joint Contributions to Hand Motion", fontweight="bold")

    def _plot_polynomial_orders(self, ax, coefficients):
        """Analyze which polynomial orders are most significant."""
        order_magnitudes = {i: [] for i in range(7)}

        for joint, coeffs in coefficients.items():
            for i, coeff_name in enumerate(["A", "B", "C", "D", "E", "F", "G"]):
                if coeff_name in coeffs:
                    order_magnitudes[i].append(abs(coeffs[coeff_name]))

        # Calculate mean magnitude for each order
        mean_magnitudes = []
        for i in range(7):
            if order_magnitudes[i]:
                mean_magnitudes.append(np.mean(order_magnitudes[i]))
            else:
                mean_magnitudes.append(0)

        ax.bar(range(7), mean_magnitudes, color="lightgreen", edgecolor="darkgreen")
        ax.set_xlabel("Polynomial Order")
        ax.set_ylabel("Mean Coefficient Magnitude")
        ax.set_title("Polynomial Order Significance", fontweight="bold")
        ax.set_xticks(range(7))
        ax.set_xticklabels(
            ["A (0)", "B (1)", "C (2)", "D (3)", "E (4)", "F (5)", "G (6)"]
        )
        ax.grid(True, alpha=0.3, axis="y")


def run_complete_demo():
    """
    Run a complete demonstration of the motion matching system.
    """
    print("=" * 80)
    print("GOLF SWING MOTION MATCHING DEMONSTRATION")
    print("=" * 80)

    # Check for required files
    wiffle_file = "Wiffle_ProV1_club_3D_data.xlsx"
    trial_file = "trial_011_20250802_205003.csv"

    if not os.path.exists(wiffle_file):
        print(f"Error: Wiffle file not found: {wiffle_file}")
        return

    if not os.path.exists(trial_file):
        print(f"Warning: Trial file not found: {trial_file}")
        print("Will proceed without initial coefficients")
        trial_file = None

    # Create output directory with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = f"motion_matching_results_{timestamp}"

    # Initialize system
    print("\n1. Initializing motion matching system...")
    system = GolfSwingMotionMatching(output_dir=output_dir)

    # Load motion capture data
    print("\n2. Loading motion capture data...")
    mocap_data = system.load_wiffle_data(wiffle_file, sheet_name="TW_ProV1")

    print(f"   - Loaded {len(mocap_data['time'])} frames")
    print(f"   - Duration: {mocap_data['time'][-1]:.2f} seconds")
    print(f"   - Hand trajectory shape: {mocap_data['midhand_positions'].shape}")

    # Load trial data if available
    initial_coeffs = None
    if trial_file:
        print("\n3. Loading initial coefficients from trial data...")
        initial_coeffs = system.load_trial_data(trial_file)
        print(f"   - Loaded coefficients for {len(initial_coeffs)} joints")

    # Optimize coefficients
    print("\n4. Optimizing polynomial coefficients...")
    print("   - Specified joints for optimization:", system.specified_joints)

    optimized_coeffs = system.optimize_coefficients(initial_coeffs)

    # Save results
    print("\n5. Saving results...")
    system.save_results()

    # Additional analysis
    print("\n6. Performing additional analysis...")
    analyzer = MotionAnalyzer()

    # Analyze joint contributions
    contributions = analyzer.analyze_joint_contributions(
        optimized_coeffs, mocap_data["midhand_positions"]
    )

    # Create analysis plots
    analyzer.plot_joint_analysis(
        optimized_coeffs, mocap_data, output_dir=os.path.join(output_dir, "analysis")
    )

    # Generate summary report
    print("\n7. Generating summary report...")
    generate_summary_report(system, analyzer, optimized_coeffs, mocap_data, output_dir)

    # Show visualization
    print("\n8. Starting interactive visualization...")
    print("   Controls:")
    print("   - Time slider: Scrub through the motion")
    print("   - Play button: Animate the motion")
    print("   - Reset button: Return to start")
    print("   - Checkboxes: Toggle skeleton and trajectory display")

    system.visualizer.show()

    print("\n" + "=" * 80)
    print("DEMONSTRATION COMPLETE!")
    print("=" * 80)
    print(f"All results saved to: {output_dir}")
    print("\nGenerated files:")
    print(f"  - {output_dir}/optimized_coefficients.json")
    print(f"  - {output_dir}/golf_swing_coefficients.m")
    print(f"  - {output_dir}/optimization_loss.png")
    print(f"  - {output_dir}/analysis/joint_analysis.png")
    print(f"  - {output_dir}/summary_report.txt")


def generate_summary_report(system, analyzer, coefficients, mocap_data, output_dir):
    """
    Generate a comprehensive summary report.
    """
    report_file = os.path.join(output_dir, "summary_report.txt")

    with open(report_file, "w") as f:
        f.write("GOLF SWING MOTION MATCHING SUMMARY REPORT\n")
        f.write("=" * 60 + "\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        # Motion capture data summary
        f.write("MOTION CAPTURE DATA\n")
        f.write("-" * 30 + "\n")
        f.write(f"Duration: {mocap_data['time'][-1]:.2f} seconds\n")
        f.write(f"Number of frames: {len(mocap_data['time'])}\n")
        f.write(
            f"Frame rate: {len(mocap_data['time'])/mocap_data['time'][-1]:.1f} Hz\n"
        )

        # Hand trajectory statistics
        hand_pos = mocap_data["midhand_positions"]
        f.write("\nHand midpoint trajectory:\n")
        f.write(
            f"  X range: [{hand_pos[:, 0].min():.3f}, {hand_pos[:, 0].max():.3f}] m\n"
        )
        f.write(
            f"  Y range: [{hand_pos[:, 1].min():.3f}, {hand_pos[:, 1].max():.3f}] m\n"
        )
        f.write(
            f"  Z range: [{hand_pos[:, 2].min():.3f}, {hand_pos[:, 2].max():.3f}] m\n"
        )

        # Optimization results
        f.write("\n\nOPTIMIZATION RESULTS\n")
        f.write("-" * 30 + "\n")
        f.write(f"Specified joints: {', '.join(system.specified_joints)}\n")
        f.write(f"Total joints in model: {len(coefficients)}\n")

        # Coefficient statistics
        f.write("\n\nCOEFFICIENT STATISTICS\n")
        f.write("-" * 30 + "\n")

        for joint in system.specified_joints:
            if joint in coefficients:
                f.write(f"\n{joint}:\n")
                for coeff_name in ["A", "B", "C", "D", "E", "F", "G"]:
                    if coeff_name in coefficients[joint]:
                        value = coefficients[joint][coeff_name]
                        f.write(f"  {coeff_name}: {value:12.6f}\n")

        # Joint velocity analysis
        velocities = analyzer.compute_joint_velocities(
            coefficients, time_duration=mocap_data["time"][-1]
        )

        f.write("\n\nJOINT VELOCITY ANALYSIS\n")
        f.write("-" * 30 + "\n")
        f.write("Maximum angular velocities (top 10):\n")

        sorted_joints = sorted(
            velocities.keys(), key=lambda j: velocities[j]["max_velocity"], reverse=True
        )[:10]

        for joint in sorted_joints:
            max_vel = velocities[joint]["max_velocity"]
            f.write(f"  {joint:15s}: {np.rad2deg(max_vel):8.1f} deg/s\n")

        f.write("\n\nEND OF REPORT\n")

    print(f"Summary report saved: {report_file}")


def create_matlab_simulation_script(coefficients, output_dir):
    """
    Create a MATLAB script that can run the simulation with optimized coefficients.
    """
    matlab_script = os.path.join(output_dir, "run_golf_simulation.m")

    with open(matlab_script, "w") as f:
        f.write(
            "% MATLAB script to run golf swing simulation with optimized coefficients\n"
        )
        f.write(f"% Generated: {datetime.now().isoformat()}\n\n")

        f.write("% Load optimized coefficients\n")
        f.write("run('golf_swing_coefficients.m');\n\n")

        f.write("% Set simulation parameters\n")
        f.write("sim_duration = 1.0;  % seconds\n")
        f.write("sim_timestep = 0.001;  % seconds\n\n")

        f.write("% Initialize simulation model\n")
        f.write("% (Add your specific model initialization here)\n\n")

        f.write("% Run simulation\n")
        f.write("% sim('your_golf_swing_model');\n\n")

        f.write("% Plot results\n")
        f.write("figure;\n")
        f.write("subplot(2,1,1);\n")
        f.write("plot(time, hand_position);\n")
        f.write("xlabel('Time (s)');\n")
        f.write("ylabel('Position (m)');\n")
        f.write("title('Hand Position vs Time');\n")
        f.write("grid on;\n\n")

        f.write("subplot(2,1,2);\n")
        f.write("plot(time, club_head_speed);\n")
        f.write("xlabel('Time (s)');\n")
        f.write("ylabel('Speed (m/s)');\n")
        f.write("title('Club Head Speed vs Time');\n")
        f.write("grid on;\n")

    print(f"MATLAB simulation script created: {matlab_script}")


if __name__ == "__main__":
    # Run the complete demonstration
    run_complete_demo()

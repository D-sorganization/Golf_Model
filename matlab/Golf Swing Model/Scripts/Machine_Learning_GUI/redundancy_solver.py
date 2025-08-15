#!/usr/bin/env python3
"""
Advanced Joint Redundancy Solver for Golf Swing Motion Matching
===============================================================

This module provides intelligent joint selection for handling redundancy
in the golf swing kinematic chain. It determines which joints should be
specified directly and which should be solved to best match the target motion.

Author: Golf Swing Simulation Project
Date: 2025
"""

import json
import os

import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns


class JointRedundancySolver:
    """
    Solves the joint redundancy problem by finding the optimal set of
    joints to specify vs. solve for matching target trajectories.
    """

    def __init__(self, kinematics_model):
        """
        Initialize the redundancy solver.

        Args:
            kinematics_model: Forward kinematics model
        """
        self.kinematics = kinematics_model

        # Define joint groups and their interdependencies
        self.joint_groups = {
            "base_motion": ["TranslationX", "TranslationY", "TranslationZ"],
            "hip_rotation": ["HipX", "HipY", "HipZ"],
            "spine": ["SpineX", "SpineY", "Torso"],
            "left_shoulder_complex": ["LScapX", "LScapY", "LSX", "LSY", "LSZ"],
            "right_shoulder_complex": ["RScapX", "RScapY", "RSX", "RSY", "RSZ"],
            "left_arm": ["LE", "LF", "LWX", "LWY"],
            "right_arm": ["RE", "RF", "RWX", "RWY"],
        }

        # Joint importance weights (based on biomechanical significance)
        self.joint_weights = {
            # Base motion - very important for overall trajectory
            "TranslationX": 1.0,
            "TranslationY": 1.0,
            "TranslationZ": 1.0,
            # Hip rotation - crucial for power generation
            "HipX": 0.9,
            "HipY": 0.9,
            "HipZ": 0.9,
            # Spine - important for torso rotation
            "SpineX": 0.8,
            "SpineY": 0.7,
            "Torso": 0.85,
            # Shoulders - moderate importance
            "LScapX": 0.6,
            "LScapY": 0.6,
            "LSX": 0.7,
            "LSY": 0.7,
            "LSZ": 0.7,
            "RScapX": 0.6,
            "RScapY": 0.6,
            "RSX": 0.7,
            "RSY": 0.7,
            "RSZ": 0.7,
            # Arms - lower importance (more reactive)
            "LE": 0.5,
            "LF": 0.4,
            "LWX": 0.4,
            "LWY": 0.4,
            "RE": 0.5,
            "RF": 0.4,
            "RWX": 0.4,
            "RWY": 0.4,
        }

        # Coupling strength between joint groups
        self.group_coupling = {
            ("base_motion", "hip_rotation"): 0.8,
            ("hip_rotation", "spine"): 0.9,
            ("spine", "left_shoulder_complex"): 0.7,
            ("spine", "right_shoulder_complex"): 0.7,
            ("left_shoulder_complex", "left_arm"): 0.8,
            ("right_shoulder_complex", "right_arm"): 0.8,
            ("left_arm", "right_arm"): 0.6,  # Hands work together
        }

    def analyze_redundancy_patterns(self, target_trajectory, n_configurations=10):
        """
        Analyze different joint specification patterns to find optimal redundancy handling.

        Args:
            target_trajectory (np.array): Target hand positions [n_time, 3]
            n_configurations (int): Number of configurations to test

        Returns:
            dict: Analysis results with optimal joint selection
        """
        print("\nAnalyzing joint redundancy patterns...")

        all_joints = list(self.joint_weights.keys())
        n_joints = len(all_joints)

        # Test different numbers of specified joints
        min_specified = 6  # Minimum to constrain the system
        max_specified = 15  # Maximum to leave some freedom

        results = []

        for n_specified in range(min_specified, max_specified + 1):
            print(f"\nTesting with {n_specified} specified joints...")

            # Use importance-weighted sampling
            config_scores = []

            # Generate configurations using importance weighting
            for _ in range(n_configurations):
                # Sample joints based on weights
                probs = np.array([self.joint_weights[j] for j in all_joints])
                probs = probs / probs.sum()

                specified_joints = np.random.choice(
                    all_joints, size=n_specified, replace=False, p=probs
                ).tolist()

                # Ensure base motion is always included
                for base_joint in self.joint_groups["base_motion"]:
                    if (
                        base_joint not in specified_joints
                        and len(specified_joints) < n_specified
                    ):
                        specified_joints.append(base_joint)

                # Evaluate this configuration
                score = self._evaluate_configuration(
                    specified_joints, target_trajectory
                )

                config_scores.append(
                    {
                        "specified_joints": specified_joints,
                        "n_specified": n_specified,
                        "score": score,
                    }
                )

            # Keep best configuration for this number of joints
            best_config = min(config_scores, key=lambda x: x["score"])
            results.append(best_config)

            print(f"  Best score: {best_config['score']:.6f}")

        # Find overall best configuration
        best_result = min(results, key=lambda x: x["score"])

        print("\nOptimal configuration found:")
        print(f"  Number of specified joints: {best_result['n_specified']}")
        print(f"  Score: {best_result['score']:.6f}")

        return {
            "best_configuration": best_result,
            "all_results": results,
            "analysis": self._analyze_configuration(best_result["specified_joints"]),
        }

    def _evaluate_configuration(self, specified_joints, target_trajectory):
        """
        Evaluate a joint configuration by testing its ability to match the target.

        Args:
            specified_joints (list): Joints to specify directly
            target_trajectory (np.array): Target trajectory

        Returns:
            float: Configuration score (lower is better)
        """
        from golf_swing_motion_matching import PolynomialCoefficientOptimizer

        # Quick optimization with fewer iterations for evaluation
        optimizer = PolynomialCoefficientOptimizer(
            self.kinematics, specified_joints, time_duration=1.0
        )

        # Run brief optimization
        coeffs, losses = optimizer.optimize(target_trajectory, n_iterations=50, lr=0.05)

        # Score based on final loss and configuration quality
        final_loss = losses[-1] if losses else float("inf")

        # Add penalties for poor configurations
        config_penalty = self._compute_configuration_penalty(specified_joints)

        return final_loss + config_penalty

    def _compute_configuration_penalty(self, specified_joints):
        """
        Compute penalty for joint configuration based on biomechanical principles.

        Args:
            specified_joints (list): List of specified joints

        Returns:
            float: Configuration penalty
        """
        penalty = 0.0

        # Penalty for not including important base joints
        base_joints = self.joint_groups["base_motion"]
        n_base_included = sum(1 for j in base_joints if j in specified_joints)
        if n_base_included < 2:
            penalty += 0.1 * (2 - n_base_included)

        # Penalty for incomplete joint groups
        for group_name, group_joints in self.joint_groups.items():
            n_in_group = sum(1 for j in group_joints if j in specified_joints)
            group_size = len(group_joints)

            # Penalize partial groups (better to include all or none)
            if 0 < n_in_group < group_size:
                incompleteness = 1 - (n_in_group / group_size)
                penalty += 0.05 * incompleteness

        # Reward for maintaining coupled groups
        for (group1, group2), coupling in self.group_coupling.items():
            joints1 = self.joint_groups[group1]
            joints2 = self.joint_groups[group2]

            n1 = sum(1 for j in joints1 if j in specified_joints)
            n2 = sum(1 for j in joints2 if j in specified_joints)

            # Both groups should be similarly represented
            imbalance = abs(n1 / len(joints1) - n2 / len(joints2))
            penalty += 0.02 * coupling * imbalance

        return penalty

    def _analyze_configuration(self, specified_joints):
        """
        Analyze a joint configuration for biomechanical insights.

        Args:
            specified_joints (list): List of specified joints

        Returns:
            dict: Configuration analysis
        """
        all_joints = list(self.joint_weights.keys())
        solved_joints = [j for j in all_joints if j not in specified_joints]

        # Analyze group representation
        group_analysis = {}
        for group_name, group_joints in self.joint_groups.items():
            n_specified = sum(1 for j in group_joints if j in specified_joints)
            n_solved = len(group_joints) - n_specified

            group_analysis[group_name] = {
                "total_joints": len(group_joints),
                "n_specified": n_specified,
                "n_solved": n_solved,
                "percentage_specified": 100 * n_specified / len(group_joints),
            }

        # Compute average importance of specified vs solved joints
        specified_importance = np.mean(
            [self.joint_weights[j] for j in specified_joints]
        )
        solved_importance = (
            np.mean([self.joint_weights[j] for j in solved_joints])
            if solved_joints
            else 0
        )

        return {
            "specified_joints": specified_joints,
            "solved_joints": solved_joints,
            "group_analysis": group_analysis,
            "specified_importance": specified_importance,
            "solved_importance": solved_importance,
            "importance_ratio": specified_importance / (solved_importance + 1e-6),
        }

    def visualize_redundancy_analysis(
        self, analysis_results, output_dir="redundancy_analysis"
    ):
        """
        Create visualizations of the redundancy analysis results.

        Args:
            analysis_results (dict): Results from analyze_redundancy_patterns
            output_dir (str): Directory to save visualizations
        """
        os.makedirs(output_dir, exist_ok=True)

        # Create figure with subplots
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))

        # 1. Configuration scores vs number of specified joints
        ax1 = axes[0, 0]
        n_specified = [r["n_specified"] for r in analysis_results["all_results"]]
        scores = [r["score"] for r in analysis_results["all_results"]]

        ax1.plot(n_specified, scores, "o-", linewidth=2, markersize=8)
        best_n = analysis_results["best_configuration"]["n_specified"]
        best_score = analysis_results["best_configuration"]["score"]
        ax1.plot(best_n, best_score, "r*", markersize=15, label="Optimal")

        ax1.set_xlabel("Number of Specified Joints")
        ax1.set_ylabel("Configuration Score (lower is better)")
        ax1.set_title("Redundancy Resolution Performance", fontweight="bold")
        ax1.grid(True, alpha=0.3)
        ax1.legend()

        # 2. Joint specification matrix
        ax2 = axes[0, 1]
        self._plot_joint_specification_matrix(ax2, analysis_results["analysis"])

        # 3. Group representation
        ax3 = axes[1, 0]
        self._plot_group_representation(
            ax3, analysis_results["analysis"]["group_analysis"]
        )

        # 4. Joint importance distribution
        ax4 = axes[1, 1]
        self._plot_importance_distribution(ax4, analysis_results["analysis"])

        plt.tight_layout()
        plt.savefig(
            os.path.join(output_dir, "redundancy_analysis.png"),
            dpi=300,
            bbox_inches="tight",
        )
        plt.close()

        # Save configuration to JSON
        config_file = os.path.join(output_dir, "optimal_configuration.json")
        with open(config_file, "w") as f:
            json.dump(
                {
                    "specified_joints": analysis_results["best_configuration"][
                        "specified_joints"
                    ],
                    "solved_joints": analysis_results["analysis"]["solved_joints"],
                    "score": float(analysis_results["best_configuration"]["score"]),
                    "analysis": analysis_results["analysis"],
                },
                f,
                indent=2,
            )

        print(f"\nRedundancy analysis saved to {output_dir}")

    def _plot_joint_specification_matrix(self, ax, analysis):
        """Plot matrix showing which joints are specified vs solved."""
        all_joints = list(self.joint_weights.keys())
        n_joints = len(all_joints)

        # Create binary matrix
        matrix = np.zeros((len(self.joint_groups), n_joints))

        joint_to_idx = {j: i for i, j in enumerate(all_joints)}

        for i, (group_name, group_joints) in enumerate(self.joint_groups.items()):
            for joint in group_joints:
                j = joint_to_idx[joint]
                if joint in analysis["specified_joints"]:
                    matrix[i, j] = 1
                else:
                    matrix[i, j] = -1

        # Create custom colormap
        colors = ["lightcoral", "white", "lightgreen"]
        n_bins = 3
        cmap = sns.blend_palette(colors, n_colors=n_bins, as_cmap=True)

        im = ax.imshow(matrix, cmap=cmap, aspect="auto", vmin=-1, vmax=1)

        # Set labels
        ax.set_xticks(range(n_joints))
        ax.set_xticklabels(all_joints, rotation=90, ha="right")
        ax.set_yticks(range(len(self.joint_groups)))
        ax.set_yticklabels(list(self.joint_groups.keys()))

        ax.set_title("Joint Specification Matrix", fontweight="bold")
        ax.set_xlabel("Joints")
        ax.set_ylabel("Joint Groups")

        # Add colorbar
        cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1])
        cbar.set_ticklabels(["Solved", "N/A", "Specified"])

    def _plot_group_representation(self, ax, group_analysis):
        """Plot bar chart of group representation."""
        groups = list(group_analysis.keys())
        specified_pct = [group_analysis[g]["percentage_specified"] for g in groups]

        bars = ax.bar(groups, specified_pct, color="skyblue", edgecolor="navy")

        # Add value labels
        for bar, pct in zip(bars, specified_pct):
            height = bar.get_height()
            ax.text(
                bar.get_x() + bar.get_width() / 2.0,
                height + 1,
                f"{pct:.0f}%",
                ha="center",
                va="bottom",
            )

        ax.set_ylabel("Percentage of Joints Specified")
        ax.set_title("Joint Group Representation", fontweight="bold")
        ax.set_ylim(0, 110)
        ax.grid(True, alpha=0.3, axis="y")

        # Rotate x labels
        plt.setp(ax.xaxis.get_majorticklabels(), rotation=45, ha="right")

    def _plot_importance_distribution(self, ax, analysis):
        """Plot distribution of joint importance for specified vs solved."""
        # Get importance values
        specified_importances = [
            self.joint_weights[j] for j in analysis["specified_joints"]
        ]
        solved_importances = [self.joint_weights[j] for j in analysis["solved_joints"]]

        # Create violin plot
        data = [specified_importances, solved_importances]
        positions = [1, 2]

        parts = ax.violinplot(
            data, positions=positions, widths=0.6, showmeans=True, showmedians=True
        )

        # Customize colors
        for pc, color in zip(parts["bodies"], ["lightgreen", "lightcoral"]):
            pc.set_facecolor(color)
            pc.set_alpha(0.7)

        # Add labels
        ax.set_xticks(positions)
        ax.set_xticklabels(["Specified", "Solved"])
        ax.set_ylabel("Joint Importance Weight")
        ax.set_title("Joint Importance Distribution", fontweight="bold")
        ax.grid(True, alpha=0.3, axis="y")

        # Add mean values
        ax.text(
            1,
            ax.get_ylim()[1] * 0.95,
            f"Mean: {np.mean(specified_importances):.2f}",
            ha="center",
            fontsize=10,
        )
        ax.text(
            2,
            ax.get_ylim()[1] * 0.95,
            f"Mean: {np.mean(solved_importances):.2f}",
            ha="center",
            fontsize=10,
        )


class AdaptiveRedundancyOptimizer:
    """
    Adaptive optimizer that adjusts joint specification during optimization.
    """

    def __init__(self, kinematics_model, redundancy_solver):
        """
        Initialize adaptive optimizer.

        Args:
            kinematics_model: Forward kinematics model
            redundancy_solver: Joint redundancy solver
        """
        self.kinematics = kinematics_model
        self.redundancy_solver = redundancy_solver

    def optimize_with_adaptive_redundancy(
        self, target_trajectory, initial_specified_joints=None, n_adaptations=3
    ):
        """
        Optimize coefficients with adaptive redundancy handling.

        Args:
            target_trajectory (np.array): Target hand positions
            initial_specified_joints (list): Initial joint specification
            n_adaptations (int): Number of adaptation cycles

        Returns:
            dict: Optimization results
        """
        print("\nStarting adaptive redundancy optimization...")

        # Start with initial configuration or analyze
        if initial_specified_joints is None:
            print("Analyzing optimal joint configuration...")
            analysis = self.redundancy_solver.analyze_redundancy_patterns(
                target_trajectory, n_configurations=5
            )
            current_specified = analysis["best_configuration"]["specified_joints"]
        else:
            current_specified = initial_specified_joints

        results = []

        for adaptation in range(n_adaptations):
            print(f"\nAdaptation cycle {adaptation + 1}/{n_adaptations}")
            print(f"Specified joints: {len(current_specified)}")

            # Optimize with current configuration
            from golf_swing_motion_matching import PolynomialCoefficientOptimizer

            optimizer = PolynomialCoefficientOptimizer(
                self.kinematics, current_specified, time_duration=1.0
            )

            coeffs, losses = optimizer.optimize(
                target_trajectory, n_iterations=200, lr=0.01
            )

            # Evaluate performance
            final_loss = losses[-1]

            # Analyze joint contributions
            joint_errors = self._analyze_joint_errors(coeffs, target_trajectory)

            results.append(
                {
                    "adaptation": adaptation,
                    "specified_joints": current_specified.copy(),
                    "coefficients": coeffs,
                    "final_loss": final_loss,
                    "joint_errors": joint_errors,
                }
            )

            # Adapt configuration based on errors
            if adaptation < n_adaptations - 1:
                current_specified = self._adapt_configuration(
                    current_specified, joint_errors
                )

        # Return best result
        best_result = min(results, key=lambda x: x["final_loss"])

        print(f"\nOptimization complete. Best loss: {best_result['final_loss']:.6f}")

        return {
            "best_result": best_result,
            "all_results": results,
            "final_configuration": best_result["specified_joints"],
        }

    def _analyze_joint_errors(self, coefficients, target_trajectory):
        """
        Analyze per-joint contribution to trajectory error.

        Args:
            coefficients (dict): Current coefficients
            target_trajectory (np.array): Target trajectory

        Returns:
            dict: Joint-specific error metrics
        """
        n_time = len(target_trajectory)
        time_vec = np.linspace(0, 1, n_time)

        # Baseline with all joints
        all_angles = {}
        for joint, coeffs in coefficients.items():
            angles = np.zeros(n_time)
            for i, coeff_name in enumerate(["A", "B", "C", "D", "E", "F", "G"]):
                if coeff_name in coeffs:
                    angles += coeffs[coeff_name] * (time_vec**i)
            all_angles[joint] = angles

        # Compute baseline trajectory
        baseline_positions = []
        for t in range(n_time):
            pos, _ = self.kinematics.compute_positions(all_angles, time_idx=t)
            baseline_positions.append(pos["hand_midpoint"])
        baseline_positions = np.array(baseline_positions)

        # Analyze each joint's contribution to error
        joint_errors = {}

        for joint in coefficients.keys():
            # Zero out this joint
            test_angles = all_angles.copy()
            test_angles[joint] = np.zeros(n_time)

            # Compute trajectory without this joint
            test_positions = []
            for t in range(n_time):
                pos, _ = self.kinematics.compute_positions(test_angles, time_idx=t)
                test_positions.append(pos["hand_midpoint"])
            test_positions = np.array(test_positions)

            # Calculate error contribution
            error_contribution = np.mean(
                np.linalg.norm(baseline_positions - test_positions, axis=1)
            )

            joint_errors[joint] = {
                "error_contribution": error_contribution,
                "coefficient_magnitude": np.mean(
                    [abs(coefficients[joint].get(c, 0)) for c in "ABCDEFG"]
                ),
            }

        return joint_errors

    def _adapt_configuration(self, current_specified, joint_errors):
        """
        Adapt joint specification based on error analysis.

        Args:
            current_specified (list): Current specified joints
            joint_errors (dict): Joint error metrics

        Returns:
            list: New specified joints
        """
        all_joints = list(self.redundancy_solver.joint_weights.keys())

        # Rank joints by error contribution
        error_rankings = sorted(
            joint_errors.items(), key=lambda x: x[1]["error_contribution"], reverse=True
        )

        # Consider switching high-error solved joints with low-error specified joints
        solved_joints = [j for j in all_joints if j not in current_specified]

        # Find candidates for switching
        high_error_solved = []
        low_error_specified = []

        for joint, metrics in error_rankings:
            if joint in solved_joints and metrics["error_contribution"] > 0.1:
                high_error_solved.append(joint)
            elif joint in current_specified and metrics["error_contribution"] < 0.05:
                low_error_specified.append(joint)

        # Make switches
        new_specified = current_specified.copy()
        n_switches = min(2, len(high_error_solved), len(low_error_specified))

        for i in range(n_switches):
            # Add high-error solved joint
            if high_error_solved[i] not in new_specified:
                new_specified.append(high_error_solved[i])

            # Remove low-error specified joint
            if low_error_specified[i] in new_specified:
                new_specified.remove(low_error_specified[i])

        print(
            f"Adapted configuration: {len(current_specified)} -> {len(new_specified)} joints"
        )

        return new_specified


def demonstrate_redundancy_solver():
    """
    Demonstrate the redundancy solver with example data.
    """
    print("=" * 80)
    print("JOINT REDUNDANCY SOLVER DEMONSTRATION")
    print("=" * 80)

    # Create mock target trajectory (sine wave pattern)
    n_points = 100
    t = np.linspace(0, 2 * np.pi, n_points)
    target_trajectory = np.column_stack(
        [0.3 * np.sin(t), 0.2 * np.sin(2 * t), 0.1 * np.sin(3 * t) + 1.0]
    )

    # Initialize components
    from golf_swing_motion_matching import GolfSwingKinematics

    kinematics = GolfSwingKinematics()
    redundancy_solver = JointRedundancySolver(kinematics)

    # Analyze redundancy patterns
    print("\n1. Analyzing joint redundancy patterns...")
    analysis_results = redundancy_solver.analyze_redundancy_patterns(
        target_trajectory, n_configurations=5
    )

    print("\n2. Optimal joint configuration:")
    optimal_config = analysis_results["analysis"]
    print(f"   Specified joints ({len(optimal_config['specified_joints'])}):")
    for joint in optimal_config["specified_joints"]:
        print(f"     - {joint}")

    print(f"\n   Solved joints ({len(optimal_config['solved_joints'])}):")
    for joint in optimal_config["solved_joints"]:
        print(f"     - {joint}")

    # Visualize results
    print("\n3. Creating visualizations...")
    redundancy_solver.visualize_redundancy_analysis(
        analysis_results, output_dir="redundancy_analysis_demo"
    )

    # Test adaptive optimization
    print("\n4. Testing adaptive redundancy optimization...")
    adaptive_optimizer = AdaptiveRedundancyOptimizer(kinematics, redundancy_solver)

    adaptive_results = adaptive_optimizer.optimize_with_adaptive_redundancy(
        target_trajectory, n_adaptations=2
    )

    print("\n5. Adaptive optimization results:")
    for result in adaptive_results["all_results"]:
        print(
            f"   Adaptation {result['adaptation']}: Loss = {result['final_loss']:.6f}"
        )

    print("\n" + "=" * 80)
    print("DEMONSTRATION COMPLETE!")
    print("Results saved to: redundancy_analysis_demo/")


if __name__ == "__main__":
    demonstrate_redundancy_solver()

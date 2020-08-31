// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's DynamicsProcessor Audio Unit
///
public class AKDynamicsProcessor: AKNode, AKToggleable, AUEffect {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor)

    private var au: AUWrapper

    /// Threshold (dB) ranges from -100 to 20 (Default: -20)
    public var threshold: AUValue = -20 {
        didSet {
            threshold = (-100...20).clamp(threshold)
            au[kDynamicsProcessorParam_Threshold] = threshold
        }
    }

    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    public var headRoom: AUValue = 5 {
        didSet {
            headRoom = (0.1...40).clamp(headRoom)
            au[kDynamicsProcessorParam_HeadRoom] = headRoom
        }
    }

    /// Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    public var expansionRatio: AUValue = 2 {
        didSet {
            expansionRatio = (1...50).clamp(expansionRatio)
            au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        }
    }

    /// Expansion Threshold (rate) ranges from -120 to 0 (Default: 0)
    public var expansionThreshold: AUValue = 0 {
        didSet {
            expansionThreshold = (-120...0).clamp(expansionThreshold)
            au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        }
    }

    /// Attack Duration (secs) ranges from 0.001 to 0.3 (Default: 0.001)
    public var attackDuration: AUValue = 0.001 {
        didSet {
            attackDuration = (0.001...0.3).clamp(attackDuration)
            au[kDynamicsProcessorParam_AttackTime] = attackDuration
        }
    }

    /// Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    public var releaseDuration: AUValue = 0.05 {
        didSet {
            releaseDuration = (0.01...3).clamp(releaseDuration)
            au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        }
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    public var masterGain: AUValue = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)
            au[kDynamicsProcessorParam_MasterGain] = masterGain
        }
    }

    /// Compression Amount (dB) read only
    public var compressionAmount: AUValue {
        return au[kDynamicsProcessorParam_CompressionAmount]
    }

    /// Input Amplitude (dB) read only
    public var inputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_InputAmplitude]
    }

    /// Output Amplitude (dB) read only
    public var outputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_OutputAmplitude]
    }

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    ///   - headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    ///   - expansionRatio: Expansion Ratio (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - expansionThreshold: Expansion Threshold (rate) ranges from 1 to 50.0 (Default: 2)
    ///   - attackDuration: Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseDuration: Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///   - compressionAmount: Compression Amount (dB) ranges from -40 to 40 (Default: 0)
    ///   - inputAmplitude: Input Amplitude (dB) ranges from -40 to 40 (Default: 0)
    ///   - outputAmplitude: Output Amplitude (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        threshold: AUValue = -20,
        headRoom: AUValue = 5,
        expansionRatio: AUValue = 2,
        expansionThreshold: AUValue = 2,
        attackDuration: AUValue = 0.001,
        releaseDuration: AUValue = 0.05,
        masterGain: AUValue = 0,
        compressionAmount: AUValue = 0,
        inputAmplitude: AUValue = 0,
        outputAmplitude: AUValue = 0) {
        self.threshold = threshold
        self.headRoom = headRoom
        self.expansionRatio = expansionRatio
        self.expansionThreshold = expansionThreshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.masterGain = masterGain

        let effect = _Self.effect
        internalEffect = effect
        au = AUWrapper(effect)

        super.init(avAudioNode: effect)

        if let input = input {
            connections.append(input)
        }

        au[kDynamicsProcessorParam_Threshold] = threshold
        au[kDynamicsProcessorParam_HeadRoom] = headRoom
        au[kDynamicsProcessorParam_ExpansionRatio] = expansionRatio
        au[kDynamicsProcessorParam_ExpansionThreshold] = expansionThreshold
        au[kDynamicsProcessorParam_AttackTime] = attackDuration
        au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        au[kDynamicsProcessorParam_MasterGain] = masterGain
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        internalEffect.bypass = false
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalEffect.bypass = true
    }
}

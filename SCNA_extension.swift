//
//  SCNAction.swift
//
//  Created by Miguel Cota on 2/23/22.
//

import Foundation
import SceneKit


// used to creat a circle arund something animated
struct AnimationPosAndAngleToRot{
    var position:SCNVector3
    var rotationAlongY: CGFloat
}

struct animationTimeHolder
{
    static var lastTime: Double = 0
    
}

extension SCNAction
{
    
    
    public static func animateChanginImg(frames:[UIImage],duraton: TimeInterval) -> SCNAction
    {
        // animates the contents of the atals with a specific delay for each frame
        //let d:CGFloat = Double(fps)/Double(frames)
        let numOfFrames = frames.count
        let delta = duraton/Double(numOfFrames)
        
        let action = SCNAction.customAction(duration: duraton, action: {(n,elapsedTime) -> () in
                                            
            // make animation there
            if elapsedTime - animationTimeHolder.lastTime >= 2*delta
            {
                let percentageComplete = elapsedTime/duraton
                
                let frameNum:Int = Int(Double(numOfFrames) * percentageComplete)  // get the frame index
                
                if frameNum < 450{
                    n.geometry?.firstMaterial?.diffuse.contents = frames[frameNum]
                    animationTimeHolder.lastTime = elapsedTime
                }
                
            }
        })
        
        
        
        
        return action
    }
    public static func moveToStartCircle(center:SCNVector3,r:Float, duration:TimeInterval) -> SCNAction
    {
        // moves to the appropriet position
        var action = SCNAction()
        let newPos = SCNVector3(r+center.x/2,0,center.z/2)
        let theta = -1*atan((r+center.x/2)/(center.z/2))
        let rot = SCNAction.rotateTo(x: 0, y: CGFloat(theta), z: 0, duration: duration)
        action = SCNAction.group([SCNAction.move(to: newPos, duration: duration),rot])
        
        return action
    }
    public static func circleAround(center:SCNVector3, radius: Float, duration:TimeInterval) -> SCNAction
    {
        var action = SCNAction()
        // f = 1/T
        let displayF:Double = 120 // asume 240 for now
        let samples = duration*displayF
        let sampledCircle = creatCircle(center: center, r: radius, samples: Int(samples))
        action = deltaMoveActions(positionsAndRot: sampledCircle, d: duration)
        
        return action
    }
    private static func deltaMoveActions(positionsAndRot:[AnimationPosAndAngleToRot],d:TimeInterval) -> SCNAction
    {
        var deltaActionPos:[SCNAction] = []
        var deltaActionRot:[SCNAction] = []
        let posNum = positionsAndRot.count
        let delta_t = d/Double(posNum) // time per frame
        for posAndA in positionsAndRot
        {
            // add one action per coordinet
            let a = SCNAction.move(to: posAndA.position, duration: delta_t)
            let b = SCNAction.rotateTo(x: 0, y: posAndA.rotationAlongY, z: 0, duration: delta_t)
            deltaActionPos.append(a) // adds the action
            deltaActionRot.append(b)
        }
        print("Stat pos: \(positionsAndRot[0].position)")
        print("Ending pos: \(positionsAndRot[posNum-1].position)")
        let deltaAction = SCNAction.group([SCNAction.sequence(deltaActionPos), SCNAction.sequence(deltaActionRot)])
        return deltaAction
    }
    private static func creatCircle(center:SCNVector3, r:Float, samples: Int) -> [AnimationPosAndAngleToRot]
    {
        var sampledCircle: [AnimationPosAndAngleToRot] = []
        
        // sample n times
        
        for i in 0...samples
        {
            // compute the coordinet
            let thetha = Float(i) * 2.0 * .pi/Float(samples)
            let x = r * cos(thetha) + center.x/2
            let z = r * sin(thetha) + center.z/2
            let y: Float = 0.0 // is always 0
            let v = SCNVector3(x,y,z)
            let a = AnimationPosAndAngleToRot(position: v, rotationAlongY: -1.0*CGFloat(thetha) - .pi/2)
            sampledCircle.append(a) // adds the new vector to the array
        }
        
        return sampledCircle
        
        
    }
    
}

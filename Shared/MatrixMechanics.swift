//
//  MatrixMechanics.swift
//  Phys440HW5
//
//  Created by Broc Pashia on 3/31/22.
//

import Foundation

class MatrixMechanics: NSObject, ObservableObject{
    
    @Published var waveEquationContentArray: [plotDataType]=[]
    @Published var eigenEnergies: [Double]=[]
    @Published var wavefunctionCoefficients: [[Double]] = []
 
    
    
 
    
    
    func phix(x: Double, n: Double, potential:Potential) -> Double{
        return pow(2.0/(potential.potentialXMax-potential.potentialXMin), 0.5) * sin(n * Double.pi * x / (potential.potentialXMax-potential.potentialXMin) )
    }
    
    func integration(integrationMin:Double, integrationMax:Double, function:(Double)->Double, numberOfSteps:Int) -> Double {
        let deltaX = (integrationMax - integrationMin) / Double(numberOfSteps);
//        func step(pointOne:Double, pointTwo:Double) -> Double {
//            if (pointTwo < integrationMax){
//                return function(pointOne) + 4 * function((pointOne + pointTwo)/2) + function(pointTwo)
//            } else {
//                return function(pointOne) + 4 * function((pointOne + integrationMax-0.0001)/2) + function(integrationMax-0.0001)
//            }
//            }
            
        var sum = 0.0
        for i in 0...numberOfSteps {
            sum += function(integrationMin + Double(i) * deltaX)
//            print(sum / Double(numberOfSteps))
            }
            return sum * (integrationMax - integrationMin) / Double(numberOfSteps)
        }
    
//
    
    
    func constructHamiltonianMatrix(potential:Potential, arrSize: Int)->[[Double]]{
        var arr:[[Double]] = Array(repeating: Array(repeating: 0.0, count: arrSize), count: arrSize)
        
        for n in 1...arrSize{
        for m in 1...arrSize{
            
            func temp(xTemp:Double)->Double{
                print("PotentialVal: " + String(potential.potFunction(xTemp)) + " " + String(xTemp))
                return phix(x:xTemp, n: Double(n), potential:potential) * potential.potFunction(xTemp) * phix(x:xTemp, n: Double(m), potential:potential)
            }
            
            let potentialIntegral = integration(integrationMin: potential.potentialXMin, integrationMax: potential.potentialXMax, function: temp, numberOfSteps:100)
            
            if n == m {
                arr[n-1][m-1] = 0.5 * 7.63 * pow(Double.pi, 2) * pow(Double(m), 2) / pow(potential.potentialXMax-potential.potentialXMin, 2) + potentialIntegral
            } else {
                arr[n-1][m-1] = potentialIntegral

            }
        }
        }
//        print(arr)
        return arr
    }
    
    
    func evaluateMatrixMechanicsSchrodingerEquation(potential: Potential, arrSize: Int){
        let H = constructHamiltonianMatrix(potential: potential, arrSize: arrSize)
        
        let packedArray = pack2dArray(arr: H, rows: arrSize, cols: arrSize)
        
        let results = calculateEigenvalues(arrayForDiagonalization: packedArray)
        
//        var coefficients: [[Double]] = Array(repeating: Array(repeating: 0.0, count: arrSize), count: arrSize)

//        for m in 0 ..< arrSize{
//            for n in 0 ..< arrSize{
//
//                coefficients[n][m] = H[m][n] / (0.5 * 7.63 * pow(Double.pi, 2) * pow(Double(n+1), 2) / pow(potential.potentialXMax-potential.potentialXMin, 2) - 0.5 * 7.63 * pow(Double.pi, 2) * pow(Double(m+1), 2) / pow(potential.potentialXMax-potential.potentialXMin, 2))
//
//            }
//        }
//
//        print(coefficients)
//
        
        eigenEnergies = results.vals
        
        wavefunctionCoefficients = results.vecs
//        print(results.vals)
        
        
    }
    func plotSelectedEnergyWaveFunction(selectedEnergy:Double, potential:Potential, arrSize: Int){
        waveEquationContentArray=[]
        let numSteps = 1000.0
        let xStep = (potential.potentialXMax-potential.potentialXMin)/numSteps
//        print("xStep " + String(xStep))
        let index = eigenEnergies.firstIndex(of:selectedEnergy)
        print("Index: " + String(index!))
        let wavefunctionCoefs = wavefunctionCoefficients[index!]
//        print(wavefunctionCoefficients
//        )
        for x in stride(from: potential.potentialXMin, to: potential.potentialXMax, by:xStep){
            var sum = 0.0
        for i in 0 ..< arrSize{
            print(wavefunctionCoefs[i])
            sum += wavefunctionCoefs[i] * phix(x:x,n:Double(i+1), potential:potential)
            
        }
            
            
            waveEquationContentArray.append([.X: x, .Y: sum])
        }
        
        
        
    }
    
}
    
    



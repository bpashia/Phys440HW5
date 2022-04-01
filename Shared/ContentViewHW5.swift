//
//  ContentView.swift
//  Shared
//
//  Created by Broc Pashia on 2/25/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var potential = Potential(doInit: true)
    @ObservedObject var dataClass = PlotDataClass(fromLine:true)
    @ObservedObject var matrixMechanics = MatrixMechanics()
    enum Display: String, CaseIterable, Identifiable {
        case potential, waveEq
        var id: Self { self }
    }

    @State private var selectedDisplay: Display = .potential
    @State private var selectedEigenEnergy: Int = 0
    @State private var selectedPotential: String = "Square Well"
    @State private var matrixSize: String = "4"

    var potentials: [String] = ["Square Well", "Linear Well", "Parabolic Well","Square + Linear Well", "Square Barrier","Triangle Barrier", "Coupled Parabolic Well", "Coupled Square Well + Field" ]
    
    var body: some View {
        VStack{
        List {
            Picker("Potential", selection: $selectedPotential) {
                ForEach(potentials, id: \.self) {
                    Text($0).tag($0)
                }.onChange(of: selectedPotential){newVal in onPotentialChange()}
            }
            
            Picker("Display", selection: $selectedDisplay) {
                Text("Potential").tag(Display.potential)
                Text("Wave Function").tag(Display.waveEq)
                
            }
            if (selectedDisplay==Display.waveEq){
                Picker("Energy", selection: $selectedEigenEnergy) {
                    ForEach(0..<$matrixMechanics.eigenEnergies.count, id: \.self) { i in
                        Text("\(matrixMechanics.eigenEnergies[i].formatted(.number.grouping(.never)))").tag(i)
                    }
                }
                    
                
            }
            HStack{
            Text("Array Dimension: ")
                          .padding(.bottom, 0)
            TextField("", text: $matrixSize)
                          .padding(.horizontal)
                          .frame(width: 50)
                          .padding(.top, 0)
                          .padding(.bottom,0).border(.secondary).onChange(of: matrixSize){newVal in onPotentialChange()}
            }
            Button("Submit", action: {selectedDisplay == Display.potential ? calculateSquareWellPotential() : calculateSquareWellWaveFunction()})
            Text("Submit with Display set to Potential once for the selected potential before submitting with Display set to Wave Equation with and energy value").foregroundColor(SwiftUI.Color.red)
        }

        }
        
        CorePlot(dataForPlot: selectedDisplay == Display.potential ? $potential.contentArray : $matrixMechanics.waveEquationContentArray, changingPlotParameters: $dataClass.changingPlotParameters )

    }
    func onPotentialChange(){
        matrixMechanics.eigenEnergies=[]
        matrixMechanics.waveEquationContentArray=[]
        selectedDisplay = .potential
        potential.getPotential(potentialType: selectedPotential, xMin: 0, xMax: 10, xStep: 0.01, dataClass: dataClass)
    }
    
    func calculateSquareWellPotential(){
        dataClass.changingPlotParameters.xMax = 10.0
        
        dataClass.changingPlotParameters.yMax = 10.0
        dataClass.changingPlotParameters.lineColor = .green()
        dataClass.changingPlotParameters.title = "Potential"
        potential.getPotential(potentialType: selectedPotential, xMin: 0, xMax: 10, xStep: 0.01, dataClass: dataClass)
                               
        
        matrixMechanics.evaluateMatrixMechanicsSchrodingerEquation(potential: potential, arrSize: Int(matrixSize)!)

        
       
}
    func calculateSquareWellWaveFunction(){
        dataClass.changingPlotParameters.xMax = 10.0
        dataClass.changingPlotParameters.yMax = 1.0
        dataClass.changingPlotParameters.lineColor = .green()

        let Energy = matrixMechanics.eigenEnergies[selectedEigenEnergy]
        dataClass.changingPlotParameters.title = String(format:"Wave Function: %2.4f",Energy)

        print("Selected: " + String(selectedEigenEnergy) + " " + String(Energy))
        
        
        matrixMechanics.plotSelectedEnergyWaveFunction(selectedEnergy: Energy, potential: potential, arrSize: Int(matrixSize)!)
}
    


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


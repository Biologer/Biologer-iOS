//
//  DeleteFindingsScreen.swift
//  Biologer
//
//  Created by Nikola Popovic on 7.10.21..
//

import SwiftUI

struct DeleteFindingsScreen: View {
    
    @ObservedObject var viewModel: DeleteFindingsScreenViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .bold()
                .padding()
            Button(action: {
                viewModel.allSelected(value: false)
            }, label: {
                HStack {
                    Image(viewModel.isAllSelected ? "radio_unchecked" : "radio_checked")
                    Text(viewModel.deleteSelectedTitle)
                        .foregroundColor(Color.black)
                        .font(.callout)
                    Spacer()
                }
                .padding(.horizontal, 10)
            })
            Button(action: {
                viewModel.allSelected(value: true)
            }, label: {
                HStack {
                    Image(viewModel.isAllSelected ? "radio_checked" : "radio_unchecked")
                    Text(viewModel.deleteAllFindings)
                        .foregroundColor(Color.black)
                        .font(.callout)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            })
            HStack {
                DeleteFindingButton(title: viewModel.buttonCancel,
                                    color: Color.biologerGreenColor,
                                    width: UIScreen.screenWidth * 0.15,
                                    onTapped: { _ in
                                        viewModel.cancelTapped()
                                    })
                    .padding(.trailing, 10)
                DeleteFindingButton(title: viewModel.buttonDelete,
                                    color: Color.red,
                                    width: UIScreen.screenWidth * 0.15,
                                    onTapped: { _ in
                                        viewModel.deleteTapped()
                                    })
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1.0)
                .foregroundColor(Color.clear)
                .shadow(color: Color.black, radius: 1, x: 0, y: 0)
        )
        .frame(width: UIScreen.screenWidth * 0.6,
               alignment: .center)
    }
}

struct DeleteFindingButton: View {
    
    let title: String
    let color: Color
    let width: CGFloat?
    let onTapped: Observer<Void>
    private let defaultWidth: CGFloat = UIScreen.main.bounds.width * 0.6
    
    var body: some View {
        Button(action: {
            onTapped(())
        }, label: {
            Text(title)
                .bold()
                .foregroundColor(Color.white)
                .frame(width: width ?? defaultWidth)
        })
        .padding()
        .background(color)
        .cornerRadius(5)
        .clipped()
        .shadow(color: Color.gray, radius: 5, x: 0, y: 0)
    }
    
}

struct DeleteFindingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = DeleteFindingsScreenViewModel(selectedFinding: FindingModelFactory.getFindgins().first!,
                                                      onDeleteDone: { _ in })
        
        DeleteFindingsScreen(viewModel: viewModel)
    }
}

//
//  ContentView.swift
//  OpenGraph-Sample
//
//  Created by nakamura motoki on 2022/03/14.
//

import SwiftUI
import OpenGraph

struct ContentView: View {
    // OpenGraphData構造体のインスタンスを作成
    @State private var data = OpenGraphData()
    
    var body: some View {
        VStack{
            // サイト名を表示
            if let siteName = data.siteName {
                Text(siteName)
                    .font(.largeTitle)
                    .bold()
            }
            // 画像を読み込み表示する
            // AsyncImageは画像を非同期で読み込むことができ、読み込み中も別の処理をすることが出来る
            // 第一引数url: 表示する画像のURL
            // 第四引数placeholder: ロード操作が完了するまで表示するビューを返すクロージャ
            AsyncImage(url: data.imageURL){ image in
                image
                    .resizable()
                    .scaledToFit()
            }placeholder: {
                // 画像の読み込み中はインジケーターを表示する
                ProgressView()
            }// AsyncImage
            //
            if let type = data.type {
                Text(type)
                    .font(.callout)
                    .italic()
            }
            // タイトルを表示
            if let title = data.title {
                Text(title)
                    .font(.title)
                    .bold()
            }
            // 説明文を表示
            if let description = data.description {
                Text(description)
                    .multilineTextAlignment(.center)
            }
            // サイトへのリンクを表示
            // Textをタップするとリンク先のURLにとぶ
            if let url = data.link{
                let string = "[Link to the song](\(url))"
                Text(try! AttributedString(markdown: string))
                    .padding()
            }
        }// VStack
        .padding()
        .task {
            await fetchData()
        }
    }// body
    
    // OGPデータの取得を行うメソッド
    private func fetchData() async{
        do{
            let songURL =  "https://ticklecode.com/xcodeshortcut/#%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3"
            guard let url = URL(string: songURL) else{return}
            
            let openGraph = try await OpenGraph.fetch(url: url)
            
            let data = OpenGraphData(title: openGraph[.title],
                                     link: URL(string: openGraph[.url] ?? ""),
                                     type: openGraph[.type],
                                     siteName: openGraph[.siteName],
                                     description: openGraph[.description],
                                     imageURL: URL(string: openGraph[.image] ?? "")
            )
            self.data = data
        }catch{
            print(error)
        }
    }
}
// サイトの情報をまとめる構造体
struct OpenGraphData{
    // タイトル
    var title: String?
    // サイトのURL
    var link: URL?
    // webサイトのタイプ
    var type: String?
    // サイト名
    var siteName: String?
    // 説明文
    var description: String?
    // 画像のURL
    var imageURL: URL?
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SplineRuntime
import SwiftUI

struct SplineCustomView: View {
    let splineURL: SplineURL
    var body: some View {
        let url = splineURL.get()!
        SplineView(sceneFileURL: url)
            .ignoresSafeArea(.all)
    }
}

// TODO: Üzgünüm -20'desin. Daha dikkatli olman lazım

// TODO: Rapor için: öğrenciler haftalık alıyorlar yani kullanabilirler. Fişlerde karakod varsa ya da direkt fişi çeksin. Oradan app alsın para datasını. Gelen resimden paranın kısmını büyüt animasyonla. Bir gelişmiş versiyon: banka ile entegre bir sistem.

package ;

import jive.Navigation;
import viewmodel.MainViewModel;
import org.aswing.border.EmptyBorder;
import org.aswing.Insets;
import org.aswing.SolidBackground;
import flash.events.Event;
import jive.plaf.flat.FlatLookAndFeel;
import org.aswing.UIManager;
import flash.display.Sprite;
import flash.Lib; 
import org.aswing.AsWingManager;

import view.MainView;

class Main extends Sprite {
	 
   public function new() {
       super();
       AsWingManager.initAsStandard(Lib.current);
       UIManager.setLookAndFeel(new FlatLookAndFeel());

       var mainView: MainView = new MainView();
       var mainVM = new MainViewModel();
       mainView.dataContext = mainVM;

       Navigation.instance.addRoute("/contribute", function(after) { mainVM.openContribute.action(); });
       Navigation.instance.addRoute("/docs", function(after) { mainVM.openDocumentation.action(); });

       mainView.setBackgroundDecorator(new SolidBackground(UIManager.getColor("window")));
       mainView.setBorder(new EmptyBorder(null, Insets.createIdentic(10)));
       mainView.setSizeWH(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

       Lib.current.stage.addEventListener(Event.RESIZE, function(e) {
           mainView.setSizeWH(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
       });

       mainView.show();
   }
}

import { apiInitializer } from 'discourse/lib/api';
import FeaturedListsWrapper from '../components/featured-lists-wrapper';

export default apiInitializer('1.14.0', (api) => {
  api.renderInOutlet(settings.plugin_outlet.trim(), FeaturedListsWrapper);
});
